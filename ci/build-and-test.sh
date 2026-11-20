#!/usr/bin/env bash
# Configures, builds and tests the Velyra project in the current directory in one go, for local use. CI runs the same
# three scripts as separate steps, so running this locally gives the same result as CI.
#
# Usage: VelyraBuildUtils/ci/build-and-test.sh [build dir] [build type] [extra cmake arguments...]
#   build dir   Defaults to build-ci, so it does not touch the build folders of your IDE
#   build type  Defaults to Debug
set -euo pipefail
ci_dir="$(dirname "${BASH_SOURCE[0]}")"

export VL_BUILD_DIR="${1:-${VL_BUILD_DIR:-build-ci}}"
export VL_BUILD_TYPE="${2:-${VL_BUILD_TYPE:-Debug}}"
shift $(( $# > 2 ? 2 : $# ))

bash "$ci_dir/configure.sh" "$@"
bash "$ci_dir/build.sh"
bash "$ci_dir/test.sh"
