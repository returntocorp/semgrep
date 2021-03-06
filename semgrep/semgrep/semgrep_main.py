import json
import logging
import time
from io import StringIO
from pathlib import Path
from re import sub
from typing import Any
from typing import Dict
from typing import List
from typing import Optional
from typing import Union

import attr

from semgrep.autofix import apply_fixes
from semgrep.config_resolver import get_config
from semgrep.constants import COMMA_SEPARATED_LIST_RE
from semgrep.constants import DEFAULT_TIMEOUT
from semgrep.constants import NOSEM_INLINE_RE
from semgrep.constants import OutputFormat
from semgrep.core_runner import CoreRunner
from semgrep.error import MISSING_CONFIG_EXIT_CODE
from semgrep.error import SemgrepError
from semgrep.output import OutputHandler
from semgrep.output import OutputSettings
from semgrep.profile_manager import ProfileManager
from semgrep.rule import Rule
from semgrep.rule_match import RuleMatch
from semgrep.target_manager import TargetManager

logger = logging.getLogger(__name__)


def notify_user_of_work(
    filtered_rules: List[Rule],
    include: List[str],
    exclude: List[str],
    verbose: bool = False,
) -> None:
    """
    Notify user of what semgrep is about to do, including:
    - number of rules
    - which rules? <- not yet, too cluttered
    - which dirs are excluded, etc.
    """
    if include:
        logger.info(f"including files:")
        for inc in include:
            logger.info(f"- {inc}")
    if exclude:
        logger.info(f"excluding files:")
        for exc in exclude:
            logger.info(f"- {exc}")
    logger.info(f"running {len(filtered_rules)} rules...")
    if verbose:
        logger.info("rules:")
        for rule in filtered_rules:
            logger.info(f"- {rule.id}")


def rule_match_nosem(rule_match: RuleMatch, strict: bool) -> bool:
    if not rule_match.lines:
        return False

    # Only consider the first line of a match. This will keep consistent
    # behavior on where we expect a 'nosem' comment to exist. If we allow these
    # comments on any line of a match it will get confusing as to what finding
    # the 'nosem' is referring to.
    re_match = NOSEM_INLINE_RE.search(rule_match.lines[0])
    if re_match is None:
        return False

    ids_str = re_match.groupdict()["ids"]
    if ids_str is None:
        logger.debug(
            f"found 'nosem' comment, skipping rule '{rule_match.id}' on line {rule_match.start['line']}"
        )
        return True

    # Strip quotes to allow for use of nosem as an HTML attribute inside tags.
    # HTML comments inside tags are not allowed by the spec.
    pattern_ids = {
        pattern_id.strip().strip("\"'")
        for pattern_id in COMMA_SEPARATED_LIST_RE.split(ids_str)
        if pattern_id.strip()
    }

    # Filter out ids that are not alphanum+dashes+underscores+periods.
    # This removes trailing symbols from comments, such as HTML comments `-->`
    # or C-like multiline comments `*/`.
    pattern_ids = set(filter(lambda x: not sub(r"[\w\-\.]+", "", x), pattern_ids))

    result = False
    for pattern_id in pattern_ids:
        if rule_match.id == pattern_id:
            logger.debug(
                f"found 'nosem' comment with id '{pattern_id}', skipping rule '{rule_match.id}' on line {rule_match.start['line']}"
            )
            result = result or True
        else:
            message = f"found 'nosem' comment with id '{pattern_id}', but no corresponding rule trying '{rule_match.id}'"
            if strict:
                raise SemgrepError(message)
            else:
                logger.debug(message)

    return result


def invoke_semgrep(
    config: Path,
    targets: List[Path],
    output_settings: Optional[OutputSettings] = None,
    **kwargs: Any,
) -> Union[Dict[str, Any], str]:
    """
    Return Semgrep results of 'config' on 'targets' as a dict|str

    Uses default arguments of 'semgrep_main.main' unless overwritten with 'kwargs'
    """
    if output_settings is None:
        output_settings = OutputSettings(output_format=OutputFormat.JSON)

    io_capture = StringIO()
    output_handler = OutputHandler(output_settings, stdout=io_capture)
    main(
        output_handler=output_handler,
        target=[str(t) for t in targets],
        pattern="",
        lang="",
        configs=[str(config)],
        **kwargs,
    )
    output_handler.close()

    result: Union[Dict[str, Any], str] = (
        json.loads(io_capture.getvalue())
        if output_settings.output_format.is_json()
        else io_capture.getvalue()
    )

    return result


def main(
    output_handler: OutputHandler,
    target: List[str],
    pattern: str,
    lang: str,
    configs: List[str],
    no_rewrite_rule_ids: bool = False,
    jobs: int = 1,
    include: Optional[List[str]] = None,
    exclude: Optional[List[str]] = None,
    strict: bool = False,
    autofix: bool = False,
    dryrun: bool = False,
    disable_nosem: bool = False,
    dangerously_allow_arbitrary_code_execution_from_rules: bool = False,
    no_git_ignore: bool = False,
    timeout: int = DEFAULT_TIMEOUT,
    max_memory: int = 0,
    timeout_threshold: int = 0,
    skip_unknown_extensions: bool = False,
    severity: Optional[List[str]] = None,
    report_time: bool = False,
    optimizations: str = "none",
) -> None:
    if include is None:
        include = []

    if exclude is None:
        exclude = []

    configs_obj, errors = get_config(pattern, lang, configs)
    all_rules = configs_obj.get_rules(no_rewrite_rule_ids)

    if severity is None or severity == []:
        filtered_rules = all_rules
    else:
        filtered_rules = [rule for rule in all_rules if rule.severity in severity]

    output_handler.handle_semgrep_errors(errors)

    if errors and strict:
        raise SemgrepError(
            f"run with --strict and there were {len(errors)} errors loading configs",
            code=MISSING_CONFIG_EXIT_CODE,
        )

    if not pattern:
        plural = "s" if len(configs_obj.valid) > 1 else ""
        config_id_if_single = (
            list(configs_obj.valid.keys())[0] if len(configs_obj.valid) == 1 else ""
        )
        invalid_msg = (
            f"({len(errors)} config files were invalid)" if len(errors) else ""
        )
        logger.debug(
            f"running {len(filtered_rules)} rules from {len(configs_obj.valid)} config{plural} {config_id_if_single} {invalid_msg}"
        )

        if len(configs_obj.valid) == 0:
            if len(errors) > 0:
                raise SemgrepError(
                    f"no valid configuration file found ({len(errors)} configs were invalid)",
                    code=MISSING_CONFIG_EXIT_CODE,
                )
            else:
                raise SemgrepError(
                    """You need to specify a config with --config=<semgrep.dev config name|localfile|localdirectory|url>.
If you're looking for a config to start with, there are thousands at: https://semgrep.dev
The two most popular are:
    --config=p/ci # find logic bugs, and high-confidence security vulnerabilities; recommended for CI
    --config=p/security-audit # find security audit points; noisy, not recommended for CI
""",
                    code=MISSING_CONFIG_EXIT_CODE,
                )

        notify_user_of_work(filtered_rules, include, exclude)

    respect_git_ignore = not no_git_ignore
    target_manager = TargetManager(
        includes=include,
        excludes=exclude,
        targets=target,
        respect_git_ignore=respect_git_ignore,
        output_handler=output_handler,
        skip_unknown_extensions=skip_unknown_extensions,
    )

    profiler = ProfileManager()

    start_time = time.time()
    # actually invoke semgrep
    (
        rule_matches_by_rule,
        debug_steps_by_rule,
        semgrep_errors,
        all_targets,
        profiling_data,
    ) = CoreRunner(
        allow_exec=dangerously_allow_arbitrary_code_execution_from_rules,
        jobs=jobs,
        timeout=timeout,
        max_memory=max_memory,
        timeout_threshold=timeout_threshold,
        report_time=report_time,
    ).invoke_semgrep(
        target_manager, profiler, filtered_rules, optimizations
    )
    profiler.save("total_time", start_time)

    output_handler.handle_semgrep_errors(semgrep_errors)

    rule_matches_by_rule = {
        rule: [
            attr.evolve(rule_match, is_ignored=rule_match_nosem(rule_match, strict))
            for rule_match in rule_matches
        ]
        for rule, rule_matches in rule_matches_by_rule.items()
    }

    if not disable_nosem:
        rule_matches_by_rule = {
            rule: [
                rule_match for rule_match in rule_matches if not rule_match._is_ignored
            ]
            for rule, rule_matches in rule_matches_by_rule.items()
        }

    num_findings = sum(len(v) for v in rule_matches_by_rule.values())
    stats_line = f"ran {len(filtered_rules)} rules on {len(all_targets)} files: {num_findings} findings"

    output_handler.handle_semgrep_core_output(
        rule_matches_by_rule,
        debug_steps_by_rule,
        stats_line,
        all_targets,
        profiler,
        filtered_rules,
        profiling_data,
    )

    if autofix:
        apply_fixes(rule_matches_by_rule, dryrun)
