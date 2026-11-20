#!/usr/bin/env bash
# Runs the tests of the project built by build.sh.
# Usage: VelyraBuildUtils/ci/test.sh [extra ctest arguments...]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/settings.sh"

ctest_command=(ctest --test-dir "$build_dir" --build-config "$build_type" --output-on-failure "$@")

# Tests that open a window need a display. Without one (CI, ssh) use a virtual X display, GLFW then picks X11.
if [[ "$OSTYPE" == linux* && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]] && command -v xvfb-run > /dev/null; then
    # The virtual display renders with Mesa llvmpipe, which supports OpenGL 4.5 but VelyraCore asks for a 4.6 context
    export MESA_GL_VERSION_OVERRIDE="${MESA_GL_VERSION_OVERRIDE:-4.6}"
    export MESA_GLSL_VERSION_OVERRIDE="${MESA_GLSL_VERSION_OVERRIDE:-460}"
    xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" "${ctest_command[@]}"
else
    "${ctest_command[@]}"
fi
