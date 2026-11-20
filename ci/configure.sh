#!/usr/bin/env bash
# Configures the Velyra project in the current directory with Ninja and the tests enabled.
# Usage: VelyraBuildUtils/ci/configure.sh [extra cmake arguments...]
# The build folder and type come from VL_BUILD_DIR and VL_BUILD_TYPE, see settings.sh.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/settings.sh"

cmake -S . -B "$build_dir" -G Ninja -DCMAKE_BUILD_TYPE="$build_type" -DBUILD_TESTING=ON "$@"
