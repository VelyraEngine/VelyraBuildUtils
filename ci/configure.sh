#!/usr/bin/env bash
# Configures the Velyra project in the current directory with the tests enabled: Ninja on Linux and macOS, MSVC on Windows.
# Usage: VelyraBuildUtils/ci/configure.sh [extra cmake arguments...]
# The build folder and type come from VL_BUILD_DIR and VL_BUILD_TYPE, see settings.sh.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/settings.sh"

# Windows uses the default Visual Studio generator, which finds MSVC without a developer prompt. Ninja would need the
# MSVC environment, and without it CMake silently picks whatever other compiler is on the PATH (MinGW on GitHub).
generator=(-G Ninja)
if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
    generator=()
fi

cmake -S . -B "$build_dir" "${generator[@]}" -DCMAKE_BUILD_TYPE="$build_type" -DBUILD_TESTING=ON "$@"
