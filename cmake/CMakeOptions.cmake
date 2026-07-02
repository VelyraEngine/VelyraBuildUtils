# Include guard
if (DEFINED _CMAKE_OPTIONS_CMAKE_ALREADY_INCLUDED)
    return()
endif ()
set(_CMAKE_OPTIONS_CMAKE_ALREADY_INCLUDED TRUE)

# Options
option(VL_ENABLE_COVERAGE "Enable code coverage instrumentation" OFF)
option(VL_ENABLE_SANITIZERS "Enables sanitizers such as address sanitizer and undefined behaviour sanitizer" OFF)
option(VL_ENABLE_UNITY_BUILD "Enables unity builds" ON)

# ===================== Compiler level =====================
set(VL_COMPILER_LEVEL "NORMAL" CACHE STRING "Compiler warning level")
set_property(CACHE VL_COMPILER_LEVEL PROPERTY STRINGS
    RELAXED
    NORMAL
    STRICT
)

set(_VL_VALID_BUILD_LEVELS
    RELAXED
    NORMAL
    STRICT
)

if(NOT VL_COMPILER_LEVEL IN_LIST _VL_VALID_BUILD_LEVELS)
    message(FATAL_ERROR "Invalid BUILD_LEVEL: ${VL_COMPILER_LEVEL}\n Valid values are: ${_VL_VALID_BUILD_LEVELS}"
    )
endif()

# ===================== Unity Build size =====================
set(VL_UNITY_BUILD_BATCH_SIZE 8 CACHE STRING "Unity build batch size")

if(NOT VL_UNITY_BUILD_BATCH_SIZE MATCHES "^[1-9][0-9]*$")
    message(FATAL_ERROR "VL_UNITY_BUILD_BATCH_SIZE must be a positive integer")
endif()

# Log configuration
message(STATUS "${BoldBlue}=========CMake Options=========${ColorReset}")
message(STATUS "${BoldBlue}Code Coverage = ${VL_ENABLE_COVERAGE}${ColorReset}")
message(STATUS "${BoldBlue}Sanitizers = ${VL_ENABLE_SANITIZERS}${ColorReset}")
message(STATUS "${BoldBlue}Unity Builds = ${VL_ENABLE_UNITY_BUILD}${ColorReset}")
message(STATUS "${BoldBlue}Create Test Targets = ${BUILD_TESTING}${ColorReset}")
message(STATUS "${BoldBlue}Compiler Level = ${VL_COMPILER_LEVEL}${ColorReset}")
message(STATUS "${BoldBlue}Unity Batch Size = ${VL_UNITY_BUILD_BATCH_SIZE}${ColorReset}")
