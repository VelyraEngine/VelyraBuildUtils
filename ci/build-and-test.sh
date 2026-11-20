#!/usr/bin/env bash
# Configures, builds and tests the Velyra project in the current directory. CI runs exactly this script, so running it
# locally gives the same result as CI.
#
# Usage: VelyraBuildUtils/ci/build-and-test.sh [build dir] [build type] [extra cmake arguments...]
#   build dir   Defaults to build-ci, so it does not touch the build folders of your IDE
#   build type  Defaults to Debug
set -euo pipefail

build_dir="${1:-build-ci}"
build_type="${2:-Debug}"
shift $(( $# > 2 ? 2 : $# ))

cmake -S . -B "$build_dir" -G Ninja -DCMAKE_BUILD_TYPE="$build_type" -DBUILD_TESTING=ON "$@"
cmake --build "$build_dir" --parallel

# Tests that open a window need a display. Without one (CI, ssh) use a virtual X display, GLFW then picks X11.
ctest_command=(ctest --test-dir "$build_dir" --build-config "$build_type" --output-on-failure)
if [[ "$OSTYPE" == linux* && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]] && command -v xvfb-run > /dev/null; then
    # The virtual display renders with Mesa llvmpipe, which supports OpenGL 4.5 but VelyraCore asks for a 4.6 context
    export MESA_GL_VERSION_OVERRIDE="${MESA_GL_VERSION_OVERRIDE:-4.6}"
    export MESA_GLSL_VERSION_OVERRIDE="${MESA_GLSL_VERSION_OVERRIDE:-460}"
    xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" "${ctest_command[@]}"
else
    "${ctest_command[@]}"
fi
