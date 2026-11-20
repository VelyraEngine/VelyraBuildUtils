#!/usr/bin/env bash
# Builds the project configured by configure.sh.
# Usage: VelyraBuildUtils/ci/build.sh [extra cmake --build arguments...]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/settings.sh"

cmake --build "$build_dir" --parallel "$@"
