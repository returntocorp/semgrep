import pytest


def xfail_repo(url, *, reason=None):
    return pytest.param(url, marks=pytest.mark.xfail(reason=reason, strict=True))


PASSING_REPOS = [
    "https://github.com/coinbase/bifrost",
    "https://github.com/coinbase/bip38",
    "https://github.com/coinbase/btcexport",
    "https://github.com/coinbase/coinbase-android-sdk",
    "https://github.com/coinbase/coinbase-android-sdk-example",
    "https://github.com/coinbase/coinbase-bitmonet-sdk",
    "https://github.com/coinbase/coinbase-commerce-node",
    "https://github.com/coinbase/coinbase-commerce-python",
    "https://github.com/coinbase/coinbase-exchange-node",
    "https://github.com/coinbase/coinbase-java",
    "https://github.com/coinbase/coinbase-javascript-sdk",
    "https://github.com/coinbase/coinbase-node",
    "https://github.com/coinbase/coinbase-pro-node",
    "https://github.com/coinbase/coinbase-python",
    "https://github.com/coinbase/coinbase-tip-discourse",
    "https://github.com/coinbase/dexter",
    "https://github.com/coinbase/fenrir",
    "https://github.com/coinbase/node-process-lock",
    "https://github.com/coinbase/odin",
    "https://github.com/coinbase/protoc-gen-rbi",
    "https://github.com/coinbase/pwnbot",
    "https://github.com/coinbase/rosetta-cli",
    "https://github.com/coinbase/rosetta-sdk-go",
    "https://github.com/coinbase/self-service-iam",
    "https://github.com/coinbase/solidity-workshop",
    "https://github.com/coinbase/step",
    "https://github.com/coinbase/step-asg-deployer",
    "https://github.com/coinbase/watchdog",
    "https://github.com/dropbox/AskBox",
    "https://github.com/dropbox/Developer-Samples",
    "https://github.com/dropbox/changes-client",
    "https://github.com/dropbox/changes-lxc-wrapper",
    "https://github.com/dropbox/changes-mesos-framework",
    "https://github.com/dropbox/dbx-unittest2pytest",
    "https://github.com/dropbox/dbxcli",
    "https://github.com/dropbox/dropbox-api-content-hasher",
    "https://github.com/dropbox/dropbox-api-v2-repl",
    "https://github.com/dropbox/dropbox-sdk-go-unofficial",
    "https://github.com/dropbox/dropbox-sdk-java",
    "https://github.com/dropbox/dropbox-sdk-js",
    "https://github.com/dropbox/dropbox-sdk-python",
    "https://github.com/dropbox/dropbox_hook",
    "https://github.com/dropbox/emmer",
    "https://github.com/dropbox/firebase-dropbox-oauth",
    "https://github.com/dropbox/git-rbr",
    "https://github.com/dropbox/PyHive",
    "https://github.com/dropbox/goebpf",
    "https://github.com/dropbox/goprotoc",
    "https://github.com/dropbox/grallama-panel",
    "https://github.com/dropbox/groupy",
    "https://github.com/dropbox/hermes",
    "https://github.com/dropbox/hocrux",
    "https://github.com/dropbox/hydra",
    "https://github.com/dropbox/llama",
    "https://github.com/dropbox/llama-archive",
    "https://github.com/dropbox/load_management",
    "https://github.com/dropbox/mdwebhook",
    "https://github.com/dropbox/merou",
    "https://github.com/dropbox/mypy-PyCharm-plugin",
    "https://github.com/dropbox/mypy-protobuf",
    "https://github.com/dropbox/nautilus-dropbox",
    "https://github.com/dropbox/nsot",
    "https://github.com/dropbox/othw",
    "https://github.com/dropbox/pem-converter-maven-plugin",
    "https://github.com/dropbox/pep8squad",
    "https://github.com/dropbox/presto-kafka-connector",
    "https://github.com/dropbox/puppet_run",
    "https://github.com/dropbox/pyannotate",
    "https://github.com/dropbox/pygerduty",
    "https://github.com/dropbox/pynsot",
    "https://github.com/dropbox/pytest-call-tracer",
    "https://github.com/dropbox/pytest-flakefinder",
    "https://github.com/dropbox/python-invariant",
    "https://github.com/dropbox/revision-browser",
    "https://github.com/dropbox/rules_node",
    "https://github.com/dropbox/securitybot",
    "https://github.com/dropbox/spookify",
    "https://github.com/dropbox/sqlalchemy-stubs",
    "https://github.com/dropbox/stone",
    "https://github.com/dropbox/stopwatch",
    "https://github.com/dropbox/strongpoc",
    "https://github.com/dropbox/whitegold",
    "https://github.com/dropbox/ykfipsconf",
    "https://github.com/dropbox/zinger",
    "https://github.com/returntocorp/badwords",
    "https://github.com/returntocorp/bento-report",
    "https://github.com/returntocorp/buffer-rule-tests",
    "https://github.com/returntocorp/check-docs",
    "https://github.com/returntocorp/cli",
    "https://github.com/returntocorp/flake8-click",
    "https://github.com/returntocorp/flake8-flask",
    "https://github.com/returntocorp/flake8-requests",
    "https://github.com/returntocorp/inputset-generator",
    "https://github.com/returntocorp/semgrep-action",
    "https://github.com/returntocorp/semgrep-rules",
    "https://github.com/coinbase/btcexport",
    "https://github.com/Airtable/airtable.js",
    "https://github.com/seemoo-lab/opendrop",
    "https://github.com/lightstep/lightstep-tracer-python",
    "https://github.com/draios/sysdig-inspect",
    "https://github.com/getsentry/sentry-python",
    "https://github.com/signalapp/signal-webrtc-ios",
    "https://github.com/secdev/scapy",
    "https://github.com/apache/airflow",
    "https://github.com/preset-io/elasticsearch-dbapi",
    "https://github.com/apache/libcloud",
    "https://github.com/keybase/pykeybasebot",
    "https://gitbox.apache.org/repos/asf/cassandra",
    "https://github.com/keybase/python-triplesec",
    "https://github.com/psycopg/psycopg2",
    "https://github.com/preset-io/flask-jwt-extended",
    "https://github.com/vstinner/pyperf",
    "https://github.com/mysql/mysql-connector-python",
    "https://github.com/Netflix/lemur",
    "https://github.com/mpirnat/lets-be-bad-guys",
    "https://github.com/JasonHinds13/hackable",
    "https://github.com/ab-smith/gruyere",
    "https://github.com/digininja/vuLnDAP",
    "https://github.com/dropbox/godropbox",
    "https://github.com/dropbox/trapperkeeper",
    "https://github.com/lodash/lodash",
    "https://github.com/bkimminich/juice-shop",
]

FAILING_REPOS = [
    xfail_repo("https://github.com/coinbase/react-coinbase-commerce"),
    xfail_repo("https://github.com/coinbase/bittip"),
    xfail_repo("https://github.com/coinbase/gtt-ui"),
    xfail_repo("https://github.com/coinbase/multisig-tool"),
    xfail_repo("https://github.com/dropbox/DropboxBusinessScripts"),
    xfail_repo("https://github.com/dropbox/changes"),
    xfail_repo("https://github.com/dropbox/changes-artifacts"),
    xfail_repo("https://github.com/dropbox/dbx_build_tools"),
    xfail_repo("https://github.com/dropbox/hackpad"),
    xfail_repo("https://github.com/dropbox/incubator-superset-internal"),
    xfail_repo("https://github.com/dropbox/notouch"),
    xfail_repo("https://github.com/dropbox/pyston"),
    xfail_repo("https://github.com/dropbox/pyston-perf"),
    xfail_repo("https://github.com/dropbox/pyston-testsuite"),
    xfail_repo("https://github.com/dropbox/pyxl"),
    xfail_repo("https://github.com/dropbox/questions"),
    xfail_repo(
        "https://github.com/returntocorp/bento",
        reason="has intentionally unparsable code",
    ),
    xfail_repo(
        "https://github.com/returntocorp/semgrep",
        reason="has intentionally unparsable code",
    ),
    xfail_repo("https://github.com/OWASP/NodeGoat"),
    "https://github.com/zulip/zulip",
    "https://github.com/home-assistant/home-assistant",
    xfail_repo("https://github.com/signalapp/Signal-Desktop"),
    xfail_repo("https://github.com/highcharts/highcharts"),
    xfail_repo("https://github.com/opensourceactivismtech/call-power"),
    xfail_repo(
        "https://github.com/apache/incubator-superset",
        reason=(
            "https://github.com/returntocorp/semgrep/issues/581, "
            "https://github.com/returntocorp/semgrep/issues/582"
        ),
    ),
    xfail_repo("https://github.com/nVisium/django.nV"),
    xfail_repo("https://github.com/we45/Vulnerable-Flask-App"),
    xfail_repo("https://github.com/DevSlop/Pixi"),
    xfail_repo("https://github.com/0c34/govwa"),
]

# Access this list with the `public_repo_url` fixture argument.
ALL_REPOS = FAILING_REPOS + PASSING_REPOS
