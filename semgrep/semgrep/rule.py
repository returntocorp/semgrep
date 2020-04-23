import json
from collections import namedtuple
from typing import Any
from typing import Dict
from typing import Iterator
from typing import List
from typing import Optional

from semgrep.semgrep_types import BooleanRuleExpression
from semgrep.semgrep_types import InvalidRuleSchema
from semgrep.semgrep_types import operator_for_pattern_name
from semgrep.semgrep_types import OPERATORS
from semgrep.semgrep_types import pattern_names_for_operator
from semgrep.semgrep_types import pattern_names_for_operators
from semgrep.semgrep_types import PatternId
from semgrep.semgrep_types import RuleGlobs
from semgrep.semgrep_types import YAML_VALID_PATHS_KEYS
from semgrep.semgrep_types import YAML_VALID_TOP_LEVEL_OPERATORS


class Rule:
    def __init__(self, raw: Dict[str, Any]) -> None:
        self._raw = raw
        self._expression = self._build_boolean_expression(raw)
        self.globs = self._build_rule_globs(raw)

    def _parse_boolean_expression(
        self, rule_patterns: List[Dict[str, Any]], pattern_id: int = 0, prefix: str = ""
    ) -> Iterator[BooleanRuleExpression]:
        """
        Move through the expression from the YML, yielding tuples of (operator, unique-id-for-pattern, pattern)
        """
        if not isinstance(rule_patterns, list):
            raise InvalidRuleSchema(
                f"invalid type for patterns in rule: {type(rule_patterns)} is not a list; perhaps your YAML is missing a `-` before {rule_patterns}?"
            )
        for pattern in rule_patterns:
            if not isinstance(pattern, dict):
                raise InvalidRuleSchema(
                    f"invalid type for pattern {pattern}: {type(pattern)} is not a dict"
                )
            for boolean_operator, pattern_text in pattern.items():
                operator = operator_for_pattern_name(boolean_operator)
                if isinstance(pattern_text, list):
                    sub_expression = self._parse_boolean_expression(
                        pattern_text, 0, f"{prefix}.{pattern_id}"
                    )
                    yield BooleanRuleExpression(
                        operator, None, list(sub_expression), None
                    )
                elif isinstance(pattern_text, str):
                    yield BooleanRuleExpression(
                        operator,
                        PatternId(f"{prefix}.{pattern_id}"),
                        None,
                        pattern_text,
                    )
                    pattern_id += 1
                else:
                    raise InvalidRuleSchema(
                        f"invalid type for pattern {pattern}: {type(pattern_text)}"
                    )

    def _build_boolean_expression(
        self, rule_raw: Dict[str, Any]
    ) -> BooleanRuleExpression:
        """
        Build a boolean expression from the yml lines in the rule

        """
        for pattern_name in pattern_names_for_operator(OPERATORS.AND):
            pattern = rule_raw.get(pattern_name)
            if pattern:
                return BooleanRuleExpression(
                    OPERATORS.AND, rule_raw["id"], None, rule_raw[pattern_name]
                )

        for pattern_name in pattern_names_for_operator(OPERATORS.AND_ALL):
            patterns = rule_raw.get(pattern_name)
            if patterns:
                return BooleanRuleExpression(
                    OPERATORS.AND_ALL,
                    None,
                    list(self._parse_boolean_expression(patterns)),
                    None,
                )

        for pattern_name in pattern_names_for_operator(OPERATORS.AND_EITHER):
            patterns = rule_raw.get(pattern_name)
            if patterns:
                return BooleanRuleExpression(
                    OPERATORS.AND_EITHER,
                    None,
                    list(self._parse_boolean_expression(patterns)),
                    None,
                )

        valid_top_level_keys = list(YAML_VALID_TOP_LEVEL_OPERATORS)
        raise InvalidRuleSchema(
            f"missing a pattern type in rule, expected one of {pattern_names_for_operators(valid_top_level_keys)}"
        )

    def _build_rule_globs(self, rule_raw: Dict[str, Any]) -> RuleGlobs:
        """
        Return a list of globs to be included and excluded for the given `paths:` rules.

        Glob conversion works as follows

        - path: tests/*.py -> tests/*.py
        - directory: tests -> tests/**
        - filename: *.js -> **/*.js
        """
        paths_rules = rule_raw.get("paths", [])
        globs = RuleGlobs()
        for rule in paths_rules:
            rule_type = list(rule.keys())[0] if len(rule) == 1 else None
            if rule_type not in YAML_VALID_PATHS_KEYS:
                raise InvalidRuleSchema(
                    f"each `paths:` targeting rule must have exactly one of {list(YAML_VALID_PATHS_KEYS)}"
                )

            rule_value = list(rule.values())[0]
            if rule_type.startswith("path"):
                rule_glob = rule_value
            elif rule_type.startswith("directory"):
                rule_glob = rule_value.strip("/") + "/**"
            elif rule_type.startswith("filename"):
                rule_glob = "**/" + rule_value

            glob_set = globs.excluded if rule_type.endswith("-not") else globs.included
            glob_set.add(rule_glob)

        return globs

    @property
    def id(self) -> str:
        return str(self._raw["id"])

    @property
    def message(self) -> str:
        return str(self._raw["message"])

    @property
    def severity(self) -> str:
        return str(self._raw["severity"])

    @property
    def languages(self) -> List[str]:
        languages: List[str] = self._raw["languages"]
        return languages

    @property
    def raw(self) -> Dict[str, Any]:  # type: ignore
        return self._raw

    @property
    def expression(self) -> BooleanRuleExpression:
        return self._expression

    @property
    def fix(self) -> Optional[str]:
        return self._raw.get("fix")

    @classmethod
    def from_json(cls, rule_json: Dict[str, Any]) -> "Rule":  # type: ignore
        return cls(rule_json)

    def to_json(self) -> Dict[str, Any]:
        return self._raw

    def __repr__(self) -> str:
        return json.dumps(self.to_json())
