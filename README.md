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
  need on Ubuntu (the `ubuntu-latest` runner). Each package is commented with the reason it is needed.
- `ci/configure.sh`, `ci/build.sh` and `ci/test.sh`: configure with the tests enabled (Ninja on Linux, MSVC on
  Windows), build, and run the tests. Without a display, tests run on a virtual X display (xvfb). Run them from the root of a repo. They build in
  `build-ci` as `Debug` by default; set `VL_BUILD_DIR` and `VL_BUILD_TYPE` to change that (`ci/settings.sh`).
- `ci/build-and-test.sh [build dir] [build type] [cmake args...]`: runs the three scripts above in one go, for local use.
- `ci/workflow-ubuntu.yml` and `ci/workflow-windows.yml`: the GitHub workflows every repo uses as
  `.github/workflows/ubuntu.yml` and `.github/workflows/windows.yml`. They only call the scripts above. There is one
  workflow per platform because a GitHub status badge shows the status of a whole workflow, not of a single job:

  ```markdown
  ![Ubuntu Build](https://github.com/VelyraEngine/<Repo>/actions/workflows/ubuntu.yml/badge.svg?branch=main)
  ![Windows Build](https://github.com/VelyraEngine/<Repo>/actions/workflows/windows.yml/badge.svg?branch=main)
  ```

## Usage

Include in your project's `CMakeLists.txt`:

```cmake
include(VelyraBuildUtils/VelyraBuildUtils.cmake)
```

This automatically includes all utility modules.
