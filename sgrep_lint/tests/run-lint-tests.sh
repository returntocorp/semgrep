#!/bin/bash

set -e

assert_output_equal () {
    actual_path=$1
    expected_path=$2
    if [ -z "$OVERRIDE_EXPECTED" ]; then
        echo "checking $expected_path"
        diff <(python -m json.tool $actual_path) <(python -m json.tool $expected_path)
    else
        echo "regenerating $expected_path"
        cat $actual_path > $expected_path
    fi
}

test_sgrep_local () { 
    cd "${THIS_DIR}/../";
    $SGREP --json --strict --config tests/python/eqeq.yaml tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.expected.json
    rm -f tmp.out
}

test_sgrep_relative() {
    # test relative paths
    cd "${THIS_DIR}/../";
    $SGREP --json --strict --config ../sgrep_lint/tests/python/eqeq.yaml tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.expected.relative.json
    rm -f tmp.out
}

test_sgrep_absolute() {
    cd "${THIS_DIR}/../";
    cp tests/python/eqeq.yaml /tmp
    $SGREP --json --strict --config /tmp/eqeq.yaml tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.expected.directory.json
    rm -f tmp.out
    rm -f /tmp/eqeq.yaml
}

test_sgrep_url_config() {
    cd "${THIS_DIR}/../";
    # test url paths
    $SGREP --json --strict --config=https://raw.githubusercontent.com/returntocorp/sgrep-rules/develop/template.yaml tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.expected.remote.json
    rm -f tmp.out
}

test_registry() {    
    $SGREP --json --strict --config=r2c tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.expected.registry.json
    rm -f tmp.out
}

test_sgrep_default_file() {
    cd "${THIS_DIR}/../";
    # test .sgrep.yml
    rm -rf .sgrep.yml
    $SGREP --generate-config
    $SGREP --json --strict tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.expected.template.json
    rm -f tmp.out
    rm -rf .sgrep.yml
}

test_sgrep_default_folder() {
    cd "${THIS_DIR}/../";
    # test .sgrep/ directory
    rm -rf .sgrep/ && mkdir .sgrep/
    $SGREP --generate-config
    mv .sgrep.yml .sgrep/
    $SGREP --json --strict tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.expected.template.json
    rm -f tmp.out
    rm -rf .sgrep/
}

test_sgrep_include () { 
    cd "${THIS_DIR}/../";
    $SGREP --json --strict --config tests/python/eqeq.yaml --include '*.py' tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.include.json
    rm -f tmp.out
}

test_sgrep_exclude () { 
    cd "${THIS_DIR}/../";
    $SGREP --json --strict --config tests/python/eqeq.yaml --exclude '*.py' tests/lint -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.exclude.json
    rm -f tmp.out
}

test_sgrep_exclude_dir () { 
    cd "${THIS_DIR}/../";
    $SGREP --json --strict --config tests/python/eqeq.yaml --exclude-dir 'excluded_dir' tests/lint tests/excluded_dir -o tmp.out >/dev/null
    assert_output_equal tmp.out tests/python/eqeq.exclude_dir.json
    rm -f tmp.out
}


echo "-----------------------"
echo "starting lint tests"

THIS_DIR="$(dirname "$(realpath "$0")")";

cd "${THIS_DIR}"
PYTHONPATH=.. pytest .

local_tests() {
    SGREP="./sgrep.py"
    test_sgrep_local
    test_sgrep_relative
    test_sgrep_absolute
    test_sgrep_url_config
    test_registry
    test_sgrep_default_file
    test_sgrep_default_folder
    test_sgrep_include
    test_sgrep_exclude
    test_sgrep_exclude_dir
}

docker_tests() {
    SGREP="docker run --rm -v \"\${PWD}:/home/repo\" returntocorp/sgrep:develop"
    test_sgrep_local
    #test_sgrep_relative
    #test_sgrep_absolute
    test_sgrep_url_config
    test_registry
    test_sgrep_default_file
    test_sgrep_default_folder
}

local_tests
#echo "sgrep docker develop image"
#docker_tests

# parsing bad.yaml should fail
$SGREP --strict --config tests/python/bad.yaml tests/lint && echo "bad.yaml should have failed" && exit 1

# parsing badpattern.yaml should fail
$SGREP --strict --config tests/python/badpattern.yaml tests/lint && echo "badpattern.yaml should have failed" && exit 1

# parsing bad2.yaml should fail
$SGREP --strict --config tests/python/bad2.yaml tests/lint && echo "bad2.yaml should have failed" && exit 1

# parsing bad3.yaml should fail
$SGREP --strict --config tests/python/bad3.yaml tests/lint && echo "bad3.yaml should have failed" && exit 1

# parsing bad4.yaml should fail
$SGREP --strict --config tests/python/bad4.yaml tests/lint && echo "bad4.yaml should have failed" && exit 1

# parsing good.yaml should succeed
$SGREP --strict --config=tests/python/good.yaml tests/lint

# parsing good_with_metadata.yaml should succeed
$SGREP --strict --config=tests/python/good_with_metadata.yaml tests/lint

#echo TODO: disabled sgrep-rules regression testing for now
rm -rf /tmp/sgrep-rules && git clone https://github.com/returntocorp/sgrep-rules /tmp/sgrep-rules
$SGREP --dangerously-allow-arbitrary-code-execution-from-rules --strict --test --test-ignore-todo /tmp/sgrep-rules

echo "-----------------------"
echo "all lint tests passed"
