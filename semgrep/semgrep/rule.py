from typing import Any
from typing import Dict
from typing import Iterator
from typing import List
from typing import Optional

from semgrep.equivalences import Equivalence
from semgrep.error import InvalidRuleSchemaError
from semgrep.rule_lang import EmptySpan
from semgrep.rule_lang import Span
from semgrep.rule_lang import YamlMap
from semgrep.rule_lang import YamlTree
from semgrep.rule_lang import YamlValue
from semgrep.semgrep_types import ALLOWED_GLOB_TYPES
from semgrep.semgrep_types import BooleanRuleExpression
from semgrep.semgrep_types import operator_for_pattern_name
from semgrep.semgrep_types import OPERATORS
from semgrep.semgrep_types import OPERATORS_WITH_CHILDREN
from semgrep.semgrep_types import pattern_names_for_operator
from semgrep.semgrep_types import pattern_names_for_operators
from semgrep.semgrep_types import PatternId
from semgrep.semgrep_types import YAML_VALID_TOP_LEVEL_OPERATORS


class Rule:
    def __init__(self, raw: YamlTree[YamlMap]) -> None:
        self._yaml = raw
        self._raw: Dict[str, Any] = raw.unroll_dict()
        # For tracking errors from semgrep-core
        self._pattern_spans: Dict[PatternId, Span] = {}

        paths: Dict[str, Any] = self._raw.get("paths", {})
        if not isinstance(paths, dict):
            raise InvalidRuleSchemaError(
                f"the `paths:` targeting rules must be an object with at least one of {ALLOWED_GLOB_TYPES}"
            )
        for key, value in paths.items():
            if key not in ALLOWED_GLOB_TYPES:
                raise InvalidRuleSchemaError(
                    f"the `paths:` targeting rules must each be one of {ALLOWED_GLOB_TYPES}"
                )
            if not isinstance(value, list):
                raise InvalidRuleSchemaError(
                    f"the `paths:` targeting rule values must be lists"
                )

        self._includes = paths.get("include", [])
        self._excludes = paths.get("exclude", [])

        self._expression = self._build_boolean_expression(self._yaml.value)

    def _parse_boolean_expression(
        self,
        rule_patterns: YamlTree[List[YamlTree]],
        pattern_id_idx: int = 0,
        prefix: str = "",
    ) -> Iterator[BooleanRuleExpression]:
        """
        Move through the expression from the YML, yielding tuples of (operator, unique-id-for-pattern, pattern)
        """
        if not isinstance(rule_patterns.value, list):
            raise InvalidRuleSchemaError(
                f"invalid type for patterns in rule: {type(rule_patterns.unroll()).__name__} is not a list; perhaps your YAML is missing a `-` before {rule_patterns.unroll()}?"
            )
        for rule_index, pattern_tree in enumerate(rule_patterns.value):
            pattern = pattern_tree.value
            if not isinstance(pattern, YamlMap):
                raise InvalidRuleSchemaError(
                    f"invalid type for pattern {pattern}: {type(pattern)} is not a dict"
                )
            for boolean_operator_yaml, sub_pattern in pattern.items():
                boolean_operator: str = boolean_operator_yaml.value
                operator = operator_for_pattern_name(boolean_operator)
                if operator in set(OPERATORS_WITH_CHILDREN):
                    if isinstance(sub_pattern.value, list):
                        sub_expression = self._parse_boolean_expression(
                            sub_pattern, 0, f"{prefix}.{rule_index}.{pattern_id_idx}"
                        )
                        yield BooleanRuleExpression(
                            operator=operator,
                            pattern_id=None,
                            children=list(sub_expression),
                            operand=None,
                        )
                    else:
                        raise InvalidRuleSchemaError(
                            f"operator {boolean_operator} must have children"
                        )
                else:
                    pattern_text, pattern_span = sub_pattern.value, sub_pattern.span
                    if isinstance(pattern_text, str):
                        pattern_id = PatternId(f"{prefix}.{pattern_id_idx}")
                        self._pattern_spans[pattern_id] = pattern_span
                        yield BooleanRuleExpression(
                            operator=operator,
                            pattern_id=pattern_id,
                            children=None,
                            operand=pattern_text,
                        )
                        pattern_id_idx += 1
                    else:
                        raise InvalidRuleSchemaError(
                            f"operand {boolean_operator} must be a string, but instead was {type(sub_pattern.unroll()).__name__}"
                        )

    @staticmethod
    def _validate_operand(operand: YamlValue) -> str:
        if not isinstance(operand, str):
            raise InvalidRuleSchemaError(
                f"type of `pattern` must be a string, but it was a {type(operand).__name__}"
            )
        return operand

    def _build_boolean_expression(self, rule_raw: YamlMap) -> BooleanRuleExpression:
        """
        Build a boolean expression from the yml lines in the rule
        """
        _rule_id = rule_raw["id"].unroll()
        if not isinstance(_rule_id, str):
            raise InvalidRuleSchemaError(
                f"rule id must be a string, but was {type(_rule_id).__name__}"
            )
        rule_id = PatternId(_rule_id)
        for pattern_name in pattern_names_for_operator(OPERATORS.AND):
            pattern = rule_raw.get(pattern_name)
            if pattern:
                self._pattern_spans[rule_id] = pattern.span
                return BooleanRuleExpression(
                    OPERATORS.AND,
                    rule_id,
                    None,
                    self._validate_operand(pattern.unroll()),
                )

        for pattern_name in pattern_names_for_operator(OPERATORS.REGEX):
            pattern = rule_raw.get(pattern_name)
            if pattern:
                self._pattern_spans[rule_id] = pattern.span
                return BooleanRuleExpression(
                    OPERATORS.REGEX,
                    rule_id,
                    None,
                    self._validate_operand(pattern.unroll()),
                )

        for pattern_name in pattern_names_for_operator(OPERATORS.AND_ALL):
            patterns = rule_raw.get(pattern_name)
            if patterns:
                return BooleanRuleExpression(
                    operator=OPERATORS.AND_ALL,
                    pattern_id=None,
                    children=list(self._parse_boolean_expression(patterns)),
                    operand=None,
                )

        for pattern_name in pattern_names_for_operator(OPERATORS.AND_EITHER):
            patterns = rule_raw.get(pattern_name)
            if patterns:
                return BooleanRuleExpression(
                    operator=OPERATORS.AND_EITHER,
                    pattern_id=None,
                    children=list(self._parse_boolean_expression(patterns)),
                    operand=None,
                )

        valid_top_level_keys = list(YAML_VALID_TOP_LEVEL_OPERATORS)
        raise InvalidRuleSchemaError(
            f"missing a pattern type in rule, expected one of {pattern_names_for_operators(valid_top_level_keys)}"
        )

    @property
    def includes(self) -> List[str]:
        return self._includes  # type: ignore

    @property
    def excludes(self) -> List[str]:
        return self._excludes  # type: ignore

    @property
    def id(self) -> str:
        return str(self._raw["id"])

    @property
    def message(self) -> str:
        return str(self._raw["message"])

    @property
    def metadata(self) -> Dict[str, Any]:  # type: ignore
        return self._raw.get("metadata", {})

    @property
    def severity(self) -> str:
        return str(self._raw["severity"])

    @property
    def sarif_severity(self) -> str:
        """
        SARIF v2.1.0-compliant severity string.

        See https://github.com/oasis-tcs/sarif-spec/blob/a6473580/Schemata/sarif-schema-2.1.0.json#L1566
        """
        mapping = {"INFO": "note", "ERROR": "error", "WARNING": "warning"}
        return mapping[self.severity]

    @property
    def sarif_tags(self) -> Iterator[str]:
        """
        Tags to display on SARIF-compliant UIs, such as GitHub security scans.
        """
        if "cwe" in self.metadata:
            yield "cwe"
        if "owasp" in self.metadata:
            yield "owasp"

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

    @property
    def equivalences(self) -> List[Equivalence]:
        # Use 'i' to make equivalence id's unique
        return [
            Equivalence(f"{self.id}-{i}", eq["equivalence"], self.languages)
            for i, eq in enumerate(self._raw.get(OPERATORS.EQUIVALENCES, []))
        ]

    @classmethod
    def from_json(cls, rule_json: Dict[str, Any]) -> "Rule":  # type: ignore
        yaml = YamlTree.wrap(rule_json, EmptySpan)
        return cls(yaml)

    @classmethod
    def from_yamltree(cls, rule_yaml: YamlTree[YamlMap]) -> "Rule":
        return cls(rule_yaml)

    def to_json(self) -> Dict[str, Any]:
        return self._raw

    def to_sarif(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "name": self.id,
            "shortDescription": {"text": self.message},
            "fullDescription": {"text": self.message},
            "defaultConfiguration": {"level": self.sarif_severity},
            "properties": {"precision": "very-high", "tags": list(self.sarif_tags)},
        }

    def __repr__(self) -> str:
        return f"<{self.__class__.__name__} id={self.id}>"

    def with_id(self, new_id: str) -> "Rule":
        new_yaml = YamlTree(
            value=YamlMap(dict(self._yaml.value._internal)), span=self._yaml.span
        )
        new_yaml.value[self._yaml.value.key_tree("id")] = YamlTree(
            value=new_id, span=new_yaml.value["id"].span
        )
        return Rule(new_yaml)

    @property
    def pattern_spans(self) -> Dict[PatternId, Span]:
        return self._pattern_spans
