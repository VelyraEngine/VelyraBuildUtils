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

## Usage

Include in your project's `CMakeLists.txt`:

```cmake
include(VelyraBuildUtils/VelyraBuildUtils.cmake)
```

This automatically includes all utility modules.
