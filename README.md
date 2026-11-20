# VelyraBuildUtils
Build utilities for other Velyra repos. This lib is included as a submodule in every Velyra Repo.

## CMake Modules

The following CMake utilities are available:

### Configuration.cmake
Project configuration utilities and helpers.

### PrettyColors.cmake
Colored output for CMake messages.

### CompilerFlags.cmake
Compiler flag management for different build configurations.

### FetchLibs.cmake
Utilities for fetching and managing external dependencies.

### CodeCoverage.cmake
Comprehensive code coverage analysis for C++ projects.
- Line, branch, and function coverage metrics
- Multiple report formats (HTML, XML, JSON, terminal)
- Automatic exclusion of third-party code
- GCC and Clang support

See [cmake/CodeCoverage.md](cmake/CodeCoverage.md) for detailed usage instructions.

## CI scripts

The `ci` folder holds the CI of every Velyra repo. CI changes reach a repo when its VelyraBuildUtils submodule is
updated, just like the CMake modules.

- `ci/install-deps-linux.sh`: installs the compilers and the system libraries GLFW, OpenGL and the native file dialog
  need on Ubuntu 24.04. Each package is commented with the reason it is needed.
- `ci/configure.sh`, `ci/build.sh` and `ci/test.sh`: configure with Ninja and the tests enabled, build, and run the
  tests. Without a display, tests run on a virtual X display (xvfb). Run them from the root of a repo. They build in
  `build-ci` as `Debug` by default; set `VL_BUILD_DIR` and `VL_BUILD_TYPE` to change that (`ci/settings.sh`).
- `ci/build-and-test.sh [build dir] [build type] [cmake args...]`: runs the three scripts above in one go, for local use.
- `ci/workflow-template.yml`: the GitHub workflow every repo uses as `.github/workflows/main.yml`. It only calls the
  scripts above.

## Usage

Include in your project's `CMakeLists.txt`:

```cmake
include(VelyraBuildUtils/VelyraBuildUtils.cmake)
```

This automatically includes all utility modules.
