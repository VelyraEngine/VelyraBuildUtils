# Code Coverage Module

The `CodeCoverage.cmake` module provides comprehensive code coverage analysis for C++ projects using Google Test (or other testing frameworks).

## Features

- **Multiple Coverage Metrics**: Line, branch, and function coverage
- **Multiple Report Formats**: HTML (interactive), XML (CI/CD), JSON, and terminal output
- **Tool Support**: Both lcov/genhtml and gcovr
- **Automatic Exclusions**: Third-party code, tests, and build directories
- **GCC 13+ Compatible**: Handles newer gcov output formats

## Requirements

- GCC or Clang compiler
- lcov and/or gcovr installed
- CMake 3.22+

```bash
# Ubuntu/Debian
sudo apt install lcov gcovr
```

## Quick Start

### 1. In Your CMakeLists.txt

The module is automatically included when you include `VelyraBuildUtils.cmake`. No additional include needed.

```cmake
cmake_minimum_required(VERSION 3.22)
project(MyProject)

include(VelyraBuildUtils/VelyraBuildUtils.cmake)

# Your library/executable setup
add_library(MyLib src/mylib.cpp)

# Your test setup
if(BUILD_TESTING)
    add_executable(MyTests test/test_mylib.cpp)
    target_link_libraries(MyTests MyLib GTest::gtest GTest::gtest_main)
    
    # Add coverage target
    add_coverage_target(
        TARGET_NAME MyTests
        COVERAGE_NAME coverage
        EXECUTABLE MyTests
    )
endif()
```

### 2. Configure with Coverage Enabled

```bash
cmake -B build-coverage -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE=ON -DBUILD_TESTING=ON
cmake --build build-coverage
```

### 3. Generate Coverage Reports

```bash
# HTML report (best for viewing)
cmake --build build-coverage --target coverage_gcovr_html_MyTests
xdg-open build-coverage/coverage_gcovr_MyTests/index.html

# Quick summary
cmake --build build-coverage --target coverage_summary_MyTests

# XML report (for CI/CD)
cmake --build build-coverage --target coverage_xml_MyTests
```

## Available CMake Targets

When you call `add_coverage_target()`, the following targets are created:

- `coverage_gcovr_html_<TARGET>` - HTML report with gcovr
- `coverage_html_<TARGET>` - HTML report with lcov
- `coverage_summary_<TARGET>` - Terminal summary
- `coverage_report_<TARGET>` - Detailed terminal report
- `coverage_xml_<TARGET>` - XML report (Cobertura format)
- `coverage_json_<TARGET>` - JSON report
- `coverage_clean_<TARGET>` - Clean coverage data
- `<COVERAGE_NAME>` - Main coverage target (alias to HTML report)

## Function Reference

### add_coverage_target

Adds coverage report generation targets for a test executable.

**Parameters:**
- `TARGET_NAME` (required) - Name of the test executable target
- `COVERAGE_NAME` (optional) - Name for the main coverage target (default: `${TARGET_NAME}_coverage`)
- `EXECUTABLE` (optional) - Executable to run for coverage (default: same as TARGET_NAME)
- `EXCLUDE_PATTERNS` (optional) - Additional patterns to exclude

**Example:**
```cmake
add_coverage_target(
    TARGET_NAME MyProjectTests
    COVERAGE_NAME coverage
    EXECUTABLE MyProjectTests
)
```

## Default Exclusions

The module automatically excludes:
- Test files (`test/`, `tests/`)
- External dependencies (`_deps/`, `external/`, `third_party/`)
- Build directories (`cmake-build-*/`, `build/`)
- System headers (`/usr/`)
- Third-party UI libraries (ImGui, ImPlot)

## Using in Your Projects

### Example: VelyraImage

```cmake
cmake_minimum_required(VERSION 3.22)
project(VelyraImage)

include(VelyraBuildUtils/VelyraBuildUtils.cmake)

# Library setup
add_library(VelyraImage src/Image.cpp src/ImageLoader.cpp)

# Test setup
if(BUILD_TESTING)
    enable_testing()
    
    # Fetch or find GTest
    find_package(GTest)
    if(NOT GTest_FOUND)
        include(FetchContent)
        FetchContent_Declare(googletest
            GIT_REPOSITORY https://github.com/google/googletest.git
            GIT_TAG release-1.12.1)
        FetchContent_MakeAvailable(googletest)
    endif()
    
    add_executable(TestVelyraImage 
        test/TestImage.cpp
        test/TestImageLoader.cpp
    )
    target_link_libraries(TestVelyraImage 
        VelyraImage 
        GTest::gtest 
        GTest::gtest_main
    )
    add_test(NAME ImageTests COMMAND TestVelyraImage)
    
    # Add coverage support
    add_coverage_target(
        TARGET_NAME TestVelyraImage
        COVERAGE_NAME coverage
        EXECUTABLE TestVelyraImage
    )
endif()
```

Then build and generate coverage:

```bash
cmake -B build-coverage -DENABLE_COVERAGE=ON -DBUILD_TESTING=ON
cmake --build build-coverage
cmake --build build-coverage --target coverage_summary_TestVelyraImage
```

## Coverage Metrics Explained

### Line Coverage
Percentage of executable lines that were run during tests. Most basic metric.

**Target**: 80-90%

### Branch Coverage
Percentage of conditional branches (if/else, switch) that were taken. More thorough than line coverage.

**Target**: 70-80%

### Function Coverage
Percentage of functions that were called during tests.

**Target**: 90%+

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Coverage

on: [push, pull_request]

jobs:
  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive
      
      - name: Install dependencies
        run: sudo apt install -y lcov gcovr
      
      - name: Configure
        run: cmake -B build -DENABLE_COVERAGE=ON -DBUILD_TESTING=ON
      
      - name: Build
        run: cmake --build build
      
      - name: Generate Coverage
        run: cmake --build build --target coverage_xml_MyTests
      
      - name: Upload to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: build/coverage_MyTests.xml
```

## Troubleshooting

### Parse Errors with GCC 13+

If you see errors like `UnknownLineType: %%%%%:10000-block 0`, this is expected. The module automatically adds `--gcov-ignore-parse-errors` to handle newer gcov output formats.

### No Coverage Data

Ensure:
1. Coverage is enabled: `-DENABLE_COVERAGE=ON`
2. Build type is Debug: `-DCMAKE_BUILD_TYPE=Debug`
3. Tests ran successfully
4. You're using GCC or Clang

### Third-Party Code in Reports

Add custom exclusions:

```cmake
# In VelyraBuildUtils/cmake/CodeCoverage.cmake
set(GCOVR_EXCLUDE_PATTERNS
    '.*/test/.*'
    # ... existing patterns ...
    '.*/vendor/.*'        # Add your custom pattern
)
```

## Performance Impact

Coverage builds are slower due to instrumentation:
- Compilation: 10-20% slower
- Execution: 2-3x slower
- **Never use for production builds**

Use separate build directories:
- `build-debug` - Regular debug builds
- `build-release` - Optimized builds
- `build-coverage` - Coverage instrumented builds

## Resources

- [gcov documentation](https://gcc.gnu.org/onlinedocs/gcc/Gcov.html)
- [lcov project](https://github.com/linux-test-project/lcov)
- [gcovr documentation](https://gcovr.com/)
