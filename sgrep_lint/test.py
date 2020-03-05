"""
For each directory containing YAML rules, run those rules on the file in the same directory with the same name but different extension.
E.g. eqeq.yaml runs on eqeq.py.
Validate that the output is annotated in the source file with by looking for a comment like:

 ```
 # ruleid:eqeq-is-bad
 ```
 On the preceeding line.

 """
import argparse
import collections
import json
import subprocess
import sys
from pathlib import Path
from typing import Any
from typing import Dict
from typing import List

import sgrep_main
from constants import YML_EXTENSIONS
from util import debug_print
from util import print_error_exit


def normalize_rule_id(line):
    """
    given a line like `     # ruleid:foobar`
    or `      // ruleid:foobar`
    return `foobar`
    """
    return line.strip().split(":")[1].strip()


def compute_confusion_matrix(reported, expected):
    true_positives = len(expected.intersection(reported))
    false_positives = len(reported - expected)
    true_negatives = 0  # we have no way to label "ok"
    false_negatives = len(expected - reported)

    return [true_positives, true_negatives, false_positives, false_negatives]


def _test_compute_confusion_matrix():
    tp, tn, fp, fn = compute_confusion_matrix(set([1, 2, 3, 4]), set([1]))
    assert tp == 1
    assert tn == 0
    assert fp == 3
    assert fn == 0

    tp, tn, fp, fn = compute_confusion_matrix(set([1, 2, 3, 4]), set([1, 2, 3, 4]))
    assert tp == 4
    assert tn == 0
    assert fp == 0
    assert fn == 0

    tp, tn, fp, fn = compute_confusion_matrix(set([2, 3]), set([1, 2, 3, 4]))
    assert tp == 2
    assert tn == 0
    assert fp == 0
    assert fn == 2


def score_output_json(json_out, test_files: List[Path], ignore_todo: bool):
    comment_lines: Dict[str, Dict[str, List[int]]] = collections.defaultdict(
        lambda: collections.defaultdict(list)
    )
    reported_lines: Dict[str, Dict[str, List[int]]] = collections.defaultdict(
        lambda: collections.defaultdict(list)
    )
    score_by_checkid: Dict[str, List[int]] = collections.defaultdict(
        lambda: [0, 0, 0, 0]
    )
    expected_reported_by_check_id: Dict[str, Dict[str, Any]] = collections.defaultdict(
        dict
    )
    num_todo = 0

    for test_file in test_files:
        test_file_resolved = str(test_file.resolve())
        with open(test_file_resolved) as fin:
            all_lines = fin.readlines()
            for i, line in enumerate(all_lines):
                todo_in_line = (
                    "#todoruleid:" in line
                    or "# todoruleid" in line
                    or "// todoruleid:" in line
                    or "//todoruleid:" in line
                )
                if todo_in_line:
                    num_todo += 1
                if (not ignore_todo and todo_in_line) or (
                    "#ruleid:" in line
                    or "# ruleid:" in line
                    or "//ruleid:" in line
                    or "// ruleid:" in line
                ):
                    # +1 because we are 0 based and sgrep output is not, plus skip the comment line
                    comment_lines[test_file_resolved][normalize_rule_id(line)].append(
                        i + 2
                    )

    for result in json_out["results"]:
        reported_lines[str(Path(result["path"]).resolve())][result["check_id"]].append(
            int(result["start"]["line"])
        )

    def join_keys(a, b):
        return set(a.keys()).union(set(b.keys()))

    for file_path in join_keys(comment_lines, reported_lines):
        for check_id in join_keys(comment_lines[file_path], reported_lines[file_path]):
            reported = set(reported_lines[file_path][check_id])
            expected = set(comment_lines[file_path][check_id])
            new_cm = compute_confusion_matrix(reported, expected)
            debug_print(
                f"reported lines for check {check_id}: {reported}, expected lines: {expected}, confusion matrix: {new_cm}"
            )
            expected_reported_by_check_id[check_id][file_path] = (expected, reported)
            # TODO: -- re-enable this
            # assert len(set(reported_lines[file_path][check_id])) == len(
            #    reported_lines[file_path][check_id]
            # ), f"for testing, please don't make rules that fire multiple times on the same line ({check_id} in {file_path} on lines {reported_lines[file_path][check_id]})"
            old_cm = score_by_checkid[check_id]
            score_by_checkid[check_id] = [
                old_cm[i] + new_cm[i] for i in range(len(new_cm))
            ]

    return (score_by_checkid, expected_reported_by_check_id, num_todo)


def confusion_matrix_to_string(confusion: List[int]) -> str:
    tp, tn, fp, fn = confusion[0], confusion[1], confusion[2], confusion[3]
    return f"TP: {tp}\tTN:{tn}\t FP: {fp}\t FN: {fn}"


def invoke_sgrep_lint(
    verbose: bool, strict: bool, test_files: List[Path], config: Path
):
    return sgrep_main.main(
        argparse.Namespace(
            verbose=verbose,
            strict=strict,
            no_rewrite_rule_ids=True,
            config=str(config),
            quiet=True,
            precommit=False,
            generate_config=False,
            pattern=None,
            validate=False,
            skip_pattern_validation=False,
            exclude_tests=False,
            output=None,
            error=False,
            target=[str(t) for t in test_files],
        )
    )


def generate_file_pairs(
    location: Path, ignore_todo: bool, strict: bool, sgrep_verbose: bool
):
    filenames = list(location.rglob("*"))
    no_tests = []
    tested = []
    sgrep_error = []
    print("starting tests...")
    for filename in filenames:
        if (
            filename.suffix in YML_EXTENSIONS
            and not filename.name.startswith(".")
            and not filename.parent.name.startswith(".")
        ):
            # find all filenames that have the same name but not extension, or are in a folder with the same name as a the yaml file
            yaml_file_name_without_ext = filename.with_suffix("")

            # import pdb
            # pdb.set_trace()
            children_test_files = [
                p
                for p in filenames
                if str(p.with_suffix("")) == (str(yaml_file_name_without_ext))
            ]
            # remove yaml files from the test lists
            test_files = [
                path
                for path in children_test_files
                if path.suffix not in YML_EXTENSIONS and path.is_file()
            ]
            if not len(test_files):
                no_tests.append(filename)
                continue
            # invoke sgrep
            try:
                output_json = invoke_sgrep_lint(
                    sgrep_verbose, strict, test_files, filename
                )
                tested.append(
                    (filename, score_output_json(output_json, test_files, ignore_todo))
                )
            except Exception as ex:
                print(
                    f"sgrep error running with config {filename} on {test_files}:\n{ex}"
                )
                sgrep_error.append(filename)

    if len(sgrep_error) and strict:
        print("exiting due to sgrep/config errors and strict flag")
        sys.exit(1)

    print(f"{len(no_tests)} yaml files missing tests")
    debug_print(f"missing tests: {no_tests}")
    print(f"{len(tested)} yaml files tested")
    print("check id scoring:")
    print("=" * 80)
    failed_tests = []
    total_confusion = [0, 0, 0, 0]

    for (filename, (output, expected_reported_by_check_id, num_todo)) in tested:
        print(filename)
        if not len(output.items()):
            print(f"  no checks fired (TODOs: {num_todo})")
        for check_id, (tp, tn, fp, fn) in output.items():
            good = (fp == 0) and (fn == 0)
            if not good:
                failed_tests.append(
                    (filename, check_id, expected_reported_by_check_id[check_id])
                )
            status = "✔" if good else "✖"
            todo_text = f"(TODOs: {num_todo})" if num_todo > 0 else ""
            confusion = [tp, tn, fp, fn]
            # add to the total confusion matrix
            total_confusion = [
                total_confusion[i] + confusion[i] for i in range(len(confusion))
            ]
            print(
                f"  {status} - {check_id.ljust(60)}{confusion_matrix_to_string(confusion)} {todo_text}"
            )

    print("=" * 80)
    print(f"final confusion matrix: {confusion_matrix_to_string(total_confusion)}")
    print("=" * 80)

    if len(failed_tests) > 0:
        print(f"failing rule files: ")
        for (filename, check_id, failed_test_files) in failed_tests:
            print(f" ✖ FAILED rule file: {filename} check: {check_id}")
            for test_file_path, (expected, reported) in failed_test_files.items():
                print(
                    f"              in test: {test_file_path}, expected lines: {expected} != reported: {reported}"
                )
        print(
            f"{len(failed_tests)} checks failed tests (run with verbose flag for more details)"
        )
        sys.exit(1)
    else:
        print("all tests passed")
        sys.exit(0)


def main(
    location: Path, ignore_todo: bool, verbose: bool, strict: bool, sgrep_verbose: bool
):
    global DEBUG
    DEBUG = verbose  # type: ignore
    generate_file_pairs(location, ignore_todo, strict, sgrep_verbose)


def test_main(args):
    _test_compute_confusion_matrix()
    if len(args.target) != 1:
        print_error_exit("only one target directory allowed for tests")
    target = Path(args.target[0])
    main(target, args.test_ignore_todo, args.verbose, args.strict, args.verbose)
