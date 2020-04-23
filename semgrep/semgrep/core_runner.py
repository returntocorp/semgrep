import collections
import json
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path
from typing import Any
from typing import Dict
from typing import Iterator
from typing import List
from typing import Optional
from typing import Tuple

import yaml

from semgrep.constants import PLEASE_FILE_ISSUE_TEXT
from semgrep.constants import SGREP_PATH
from semgrep.evaluation import enumerate_patterns_in_boolean_expression
from semgrep.evaluation import evaluate
from semgrep.pattern import Pattern
from semgrep.pattern_match import PatternMatch
from semgrep.rule import Rule
from semgrep.rule_match import RuleMatch
from semgrep.semgrep_types import BooleanRuleExpression
from semgrep.semgrep_types import OPERATORS
from semgrep.util import debug_print
from semgrep.util import INVALID_PATTERN_EXIT_CODE
from semgrep.util import print_error
from semgrep.util import print_error_exit


class CoreRunner:
    """
        Handles interactions between semgrep and semgrep-core

        This includes properly invoking semgrep-core and parsing the output
    """

    def __init__(
        self,
        allow_exec: bool,
        include: List[str],
        exclude: List[str],
        exclude_dir: List[str],
    ):
        self._allow_exec = allow_exec
        self._include = include
        self._exclude = exclude
        self._exclude_dir = exclude_dir

    def _flatten_rule_patterns(self, rules: List[Rule]) -> Iterator[Pattern]:
        """
            Convert list of rules to format understandable by semgrep core
        """
        for rule_index, rule in enumerate(rules):
            flat_expressions = list(
                enumerate_patterns_in_boolean_expression(rule.expression)
            )
            for expr in flat_expressions:
                if not should_send_to_semgrep_core(expr):
                    continue

                yield Pattern(rule_index, expr, rule.severity, rule.languages)

    def _group_patterns_by_langauge(
        self, rules: List[Rule]
    ) -> Dict[str, List[Pattern]]:
        # a rule can have multiple patterns inside it. Flatten these so we can send semgrep a single yml file list of patterns
        patterns = list(self._flatten_rule_patterns(rules))
        by_lang: Dict[str, List[Pattern]] = collections.defaultdict(list)
        for pattern in patterns:
            for language in pattern.languages:
                by_lang[language].append(pattern)
        return by_lang

    def _semgrep_error_json_to_message_then_exit(
        self, error_json: Dict[str, Any],
    ) -> None:
        """
        See format_output_exception in semgrep O'Caml for details on schema
        """
        error_type = error_json["error"]
        if error_type == "invalid language":
            print_error_exit(f'invalid language {error_json["language"]}')
        elif error_type == "invalid pattern":
            print_error(
                f'invalid pattern "{error_json["pattern"]}": {error_json["message"]}'
            )
            sys.exit(INVALID_PATTERN_EXIT_CODE)
        # no special formatting ought to be required for the other types; the semgrep python should be performing
        # validation for them. So if any other type of error occurs, ask the user to file an issue
        else:
            print_error_exit(
                f'an internal error occured while invoking the semgrep engine: {error_type}: {error_json.get("message", "")}.\n\n{PLEASE_FILE_ISSUE_TEXT}'
            )

    def _run_rules(
        self, rules: List[Rule], targets: List[Path]
    ) -> Tuple[Dict[Rule, Dict[Path, List[PatternMatch]]], List[Any]]:
        """
            Run all rules on targets and return list of all places that match patterns, ... todo errors
        """
        outputs: List[PatternMatch] = []  # multiple invocations per language
        errors: List[Any] = []

        for language, all_patterns_for_language in self._group_patterns_by_langauge(
            rules
        ).items():
            with tempfile.NamedTemporaryFile("w") as fout:
                # very important not to sort keys here
                patterns_json = [p.to_json() for p in all_patterns_for_language]
                yaml_as_str = yaml.safe_dump({"rules": patterns_json}, sort_keys=False)
                fout.write(yaml_as_str)
                fout.flush()
                cmd = [SGREP_PATH] + [
                    "-lang",
                    language,
                    f"-rules_file",
                    fout.name,
                    *self.targeting_options,
                    *[str(path) for path in targets],
                ]
                try:
                    output = subprocess.check_output(cmd, shell=False)
                except subprocess.CalledProcessError as ex:
                    try:
                        # see if semgrep output a JSON error that we can decode
                        semgrep_output = ex.output.decode("utf-8", "replace")
                        output_json = json.loads(semgrep_output)
                        if "error" in output_json:
                            self._semgrep_error_json_to_message_then_exit(output_json)
                        else:
                            print_error(
                                f"unexpected non-json output while invoking semgrep core with {' '.join(cmd)} \n {ex}"
                            )
                            print_error_exit(f"\n{PLEASE_FILE_ISSUE_TEXT}")
                            raise ex  # let our general exception handler take care of this
                    except Exception as e:
                        print_error(
                            f"non-zero return code while invoking semgrep with:\n\t{' '.join(cmd)}\n{ex} {e}"
                        )
                        print_error_exit(f"\n\n{PLEASE_FILE_ISSUE_TEXT}")
                output_json = json.loads((output.decode("utf-8", "replace")))
                errors.extend(output_json["errors"])
                outputs.extend([PatternMatch(m) for m in output_json["matches"]])

        # group output; we want to see all of the same rule ids on the same file path
        by_rule_index: Dict[
            Rule, Dict[Path, List[PatternMatch]]
        ] = collections.defaultdict(lambda: collections.defaultdict(list))

        for pattern_match in outputs:
            rule_index = pattern_match.rule_index
            rule = rules[rule_index]
            by_rule_index[rule][pattern_match.path].append(pattern_match)

        return by_rule_index, errors

    def _resolve_output(
        self, outputs: Dict[Rule, Dict[Path, List[PatternMatch]]],
    ) -> Dict[Rule, List[RuleMatch]]:
        """
            Takes output of all running all patterns and rules and returns Findings
        """
        findings_by_rule: Dict[Rule, List[RuleMatch]] = {}

        for rule, paths in outputs.items():
            findings = []
            for filepath, pattern_matches in paths.items():
                if not rule.globs.match(filepath):
                    continue
                debug_print(f"-------- rule ({rule.id} ------ filepath: {filepath}")

                findings.extend(evaluate(rule, pattern_matches, self._allow_exec))

            findings_by_rule[rule] = dedup_output(findings)

        return findings_by_rule

    @property
    def targeting_options(self) -> Iterator[str]:
        """Yields include/exclude CLI options to call semgrep with.

        This is based on the arguments given to semgrep-lint.
        """
        for pattern in self._include:
            yield from ["-include", pattern]
        for pattern in self._exclude:
            yield from ["-exclude", pattern]
        for pattern in self._exclude_dir:
            yield from ["-exclude-dir", pattern]

    def invoke_semgrep(
        self, targets: List[Path], rules: List[Rule],
    ) -> Tuple[Dict[Rule, List[RuleMatch]], List[Any]]:
        """
            Takes in rules and targets and retuns object with findings
        """
        start = datetime.now()

        outputs, errors = self._run_rules(rules, targets)
        findings_by_rule = self._resolve_output(outputs)

        debug_print(f"semgrep ran in {datetime.now() - start}")

        return findings_by_rule, errors


def dedup_output(outputs: List[RuleMatch]) -> List[RuleMatch]:
    return list({uniq_id(r): r for r in outputs}.values())


def uniq_id(
    r: RuleMatch,
) -> Tuple[str, Path, Optional[int], Optional[int], Optional[int], Optional[int]]:
    start = r.start
    end = r.end
    return (
        r.id,
        r.path,
        start.get("line"),
        start.get("col"),
        end.get("line"),
        end.get("col"),
    )


def should_send_to_semgrep_core(expression: BooleanRuleExpression) -> bool:
    """
    don't send rules like "and-either" or "and-all" to semgrep
    """
    return (
        expression.pattern_id is not None
        and expression.operand is not None
        and (expression.operator != OPERATORS.WHERE_PYTHON)
    )
