#!/bin/bash
## For testing release jobs, make an empty ubuntu release quickly
set -e

mkdir -p semgrep-lint-files
echo "sgrep-core" > semgrep-lint-files/sgrep
echo "sgrep-lint" > semgrep-lint-files/sgrep-lint
chmod +x semgrep-lint-files/sgrep
chmod +x semgrep-lint-files/sgrep-lint
tar -cvzf artifacts.tar.gz semgrep-lint-files/
