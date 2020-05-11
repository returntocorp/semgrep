import json
from pathlib import Path
from subprocess import CalledProcessError

import pytest


def test_basic_rule__local(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(run_semgrep_in_tmp("rules/eqeq.yaml"), "results.json")


def test_basic_rule__relative(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(
        run_semgrep_in_tmp("rules/../rules/eqeq.yaml"), "results.json",
    )


def test_basic_rule__absolute(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(
        run_semgrep_in_tmp(Path.cwd() / "rules" / "eqeq.yaml"), "results.json",
    )


def test_terminal_output(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(
        run_semgrep_in_tmp("rules/eqeq.yaml", output_format="normal"), "output.txt"
    )


def test_sarif_output(run_semgrep_in_tmp, snapshot):
    sarif_output = json.loads(
        run_semgrep_in_tmp("rules/eqeq.yaml", output_format="sarif")
    )

    # rules are logically a set so the JSON list's order doesn't matter
    # we make the order deterministic here so that snapshots match across runs
    # the proper solution will be https://github.com/joseph-roitman/pytest-snapshot/issues/14
    sarif_output["tool"]["driver"]["rules"] = sorted(
        sarif_output["tool"]["driver"]["rules"], key=lambda rule: rule["id"]
    )

    snapshot.assert_match(
        json.dumps(sarif_output, indent=2, sort_keys=True), "results.sarif"
    )


def test_url_rule(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(
        run_semgrep_in_tmp(
            "https://raw.githubusercontent.com/returntocorp/semgrep-rules/develop/template.yaml",
        ),
        "results.json",
    )


def test_registry_rule(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(
        run_semgrep_in_tmp("r2c"), "results.json",
    )


def test_hidden_rule__explicit(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(run_semgrep_in_tmp("rules/hidden/.hidden"), "results.json")


def test_hidden_rule__implicit(run_semgrep_in_tmp, snapshot):
    with pytest.raises(CalledProcessError) as excinfo:
        run_semgrep_in_tmp("rules/hidden", stderr=True)
    assert excinfo.value.returncode == 2
    snapshot.assert_match(excinfo.value.output, "error.txt")


def test_default_rule__file(run_semgrep_in_tmp, snapshot):
    Path(".semgrep.yml").symlink_to(Path("rules/eqeq.yaml").resolve())
    snapshot.assert_match(run_semgrep_in_tmp(), "results.json")


def test_default_rule__folder(run_semgrep_in_tmp, snapshot):
    Path(".semgrep").mkdir()
    Path(".semgrep/.semgrep.yml").symlink_to(Path("rules/eqeq.yaml").resolve())

    snapshot.assert_match(run_semgrep_in_tmp(), "results.json")
