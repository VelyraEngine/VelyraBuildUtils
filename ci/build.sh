#!/usr/bin/env bash
# Builds the project configured by configure.sh.
# Usage: VelyraBuildUtils/ci/build.sh [extra cmake --build arguments...]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/settings.sh"

# --config picks the configuration for multi-config generators (Visual Studio) and is ignored by Ninja
cmake --build "$build_dir" --config "$build_type" --parallel "$@"
