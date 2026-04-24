# Code Coverage Configuration for Velyra Targets
#
# This module provides functions to enable code coverage metrics for C++ projects
# using gcov/lcov or gcovr.
#
# Usage:
#   include(cmake/CodeCoverage.cmake)
#   add_coverage_target(TARGET_NAME target_name COVERAGE_NAME coverage_report_name)
#
# Requirements:
#   - GCC or Clang compiler
#   - lcov and/or gcovr installed

option(ENABLE_COVERAGE "Enable code coverage instrumentation" OFF)

if(ENABLE_COVERAGE)
    message(STATUS "Code coverage instrumentation enabled")
    
    # Check for required tools
    find_program(LCOV_PATH lcov)
    find_program(GENHTML_PATH genhtml)
    find_program(GCOVR_PATH gcovr)
    
    if(NOT LCOV_PATH)
        message(WARNING "lcov not found. Install with: sudo apt install lcov")
    endif()
    
    if(NOT GCOVR_PATH)
        message(WARNING "gcovr not found. Install with: sudo apt install gcovr")
    endif()
    
    # Add coverage compiler flags
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        set(COVERAGE_COMPILER_FLAGS "--coverage -fprofile-arcs -ftest-coverage -fno-inline -fno-inline-small-functions -fno-default-inline -O0 -g")
        set(COVERAGE_LINKER_FLAGS "--coverage")
        
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COVERAGE_COMPILER_FLAGS}")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COVERAGE_COMPILER_FLAGS}")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${COVERAGE_LINKER_FLAGS}")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${COVERAGE_LINKER_FLAGS}")
        
        message(STATUS "Coverage flags added: ${COVERAGE_COMPILER_FLAGS}")
    else()
        message(FATAL_ERROR "Code coverage requires GCC or Clang compiler")
    endif()
else()
    message(STATUS "Code coverage instrumentation disabled (use -DENABLE_COVERAGE=ON to enable)")
endif()

# Function to add coverage targets
function(add_coverage_target)
    if(NOT ENABLE_COVERAGE)
        return()
    endif()
    
    set(options)
    set(oneValueArgs TARGET_NAME COVERAGE_NAME EXECUTABLE)
    set(multiValueArgs EXCLUDE_PATTERNS)
    cmake_parse_arguments(COV "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT COV_TARGET_NAME)
        message(FATAL_ERROR "add_coverage_target requires TARGET_NAME argument")
    endif()
    
    if(NOT COV_COVERAGE_NAME)
        set(COV_COVERAGE_NAME "${COV_TARGET_NAME}_coverage")
    endif()
    
    if(NOT COV_EXECUTABLE)
        set(COV_EXECUTABLE ${COV_TARGET_NAME})
    endif()
    
    # Default exclude patterns (glob syntax for lcov)
    set(LCOV_EXCLUDE_PATTERNS
        '*/test/*'
        '*/tests/*'
        '*/cmake-build-*/*'
        '*/build/*'
        '*/usr/*'
        '*/_deps/*'
        '*/external/*'
        '*/third_party/*'
        '*/v1/*'
        '*/ImGui/*'
        '*/imgui/*'
        '*/implot/*'
    )
    
    # Default exclude patterns (regex syntax for gcovr)
    set(GCOVR_EXCLUDE_PATTERNS
        '.*/test/.*'
        '.*/tests/.*'
        '.*/cmake-build-.*/.*'
        '.*/build/.*'
        '.*/usr/.*'
        '.*/_deps/.*'
        '.*/external/.*'
        '.*/third_party/.*'
        '.*/v1/.*'
        '.*/ImGui/.*'
        '.*/imgui.*'
        '.*/implot.*'
    )
    
    if(COV_EXCLUDE_PATTERNS)
        list(APPEND LCOV_EXCLUDE_PATTERNS ${COV_EXCLUDE_PATTERNS})
        list(APPEND GCOVR_EXCLUDE_PATTERNS ${COV_EXCLUDE_PATTERNS})
    endif()
    
    # Build exclude string for lcov
    set(LCOV_EXCLUDES)
    foreach(PATTERN ${LCOV_EXCLUDE_PATTERNS})
        list(APPEND LCOV_EXCLUDES --remove coverage.info ${PATTERN})
    endforeach()
    
    # Build exclude string for gcovr
    set(GCOVR_EXCLUDES)
    foreach(PATTERN ${GCOVR_EXCLUDE_PATTERNS})
        string(REPLACE "'" "" PATTERN_CLEAN ${PATTERN})
        list(APPEND GCOVR_EXCLUDES "--exclude=${PATTERN_CLEAN}")
    endforeach()
    
    # Target to clean coverage data
    add_custom_target(coverage_clean_${COV_TARGET_NAME}
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/coverage_${COV_TARGET_NAME}
        COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
        COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcno" -delete
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Cleaning coverage data for ${COV_TARGET_NAME}"
    )
    
    if(LCOV_PATH AND GENHTML_PATH)
        # LCOV-based HTML coverage report
        add_custom_target(coverage_html_${COV_TARGET_NAME}
            # Clean old coverage data
            COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
            
            # Run tests
            COMMAND ${CMAKE_COMMAND} -E echo "Running tests for coverage..."
            COMMAND $<TARGET_FILE:${COV_EXECUTABLE}>
            
            # Capture coverage data
            COMMAND ${CMAKE_COMMAND} -E echo "Capturing coverage data..."
            COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --capture --output-file coverage.info --rc lcov_branch_coverage=1
            
            # Remove excluded files
            COMMAND ${CMAKE_COMMAND} -E echo "Filtering coverage data..."
            COMMAND ${LCOV_PATH} ${LCOV_EXCLUDES} --output-file coverage_filtered.info --rc lcov_branch_coverage=1
            
            # Generate HTML report
            COMMAND ${CMAKE_COMMAND} -E echo "Generating HTML report..."
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/coverage_${COV_TARGET_NAME}
            COMMAND ${GENHTML_PATH} coverage_filtered.info --output-directory ${CMAKE_BINARY_DIR}/coverage_${COV_TARGET_NAME} --branch-coverage --function-coverage
            
            COMMAND ${CMAKE_COMMAND} -E echo "Coverage report generated at: ${CMAKE_BINARY_DIR}/coverage_${COV_TARGET_NAME}/index.html"
            
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${COV_EXECUTABLE}
            COMMENT "Generating HTML coverage report for ${COV_TARGET_NAME}"
        )
    endif()
    
    if(GCOVR_PATH)
        # GCOVR-based reports (supports multiple output formats)
        
        # HTML report with gcovr
        add_custom_target(coverage_gcovr_html_${COV_TARGET_NAME}
            COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
            COMMAND ${CMAKE_COMMAND} -E echo "Running tests for coverage..."
            COMMAND $<TARGET_FILE:${COV_EXECUTABLE}>
            COMMAND ${CMAKE_COMMAND} -E echo "Generating HTML coverage report with gcovr..."
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/coverage_gcovr_${COV_TARGET_NAME}
            COMMAND ${GCOVR_PATH} --root ${CMAKE_SOURCE_DIR} ${GCOVR_EXCLUDES} 
                --gcov-ignore-parse-errors
                --html --html-details 
                --output ${CMAKE_BINARY_DIR}/coverage_gcovr_${COV_TARGET_NAME}/index.html
                --print-summary
            COMMAND ${CMAKE_COMMAND} -E echo "Coverage report generated at: ${CMAKE_BINARY_DIR}/coverage_gcovr_${COV_TARGET_NAME}/index.html"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${COV_EXECUTABLE}
            COMMENT "Generating HTML coverage report with gcovr for ${COV_TARGET_NAME}"
        )
        
        # XML report (Cobertura format - good for CI/CD)
        add_custom_target(coverage_xml_${COV_TARGET_NAME}
            COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
            COMMAND ${CMAKE_COMMAND} -E echo "Running tests for coverage..."
            COMMAND $<TARGET_FILE:${COV_EXECUTABLE}>
            COMMAND ${CMAKE_COMMAND} -E echo "Generating XML coverage report..."
            COMMAND ${GCOVR_PATH} --root ${CMAKE_SOURCE_DIR} ${GCOVR_EXCLUDES}
                --gcov-ignore-parse-errors
                --xml --xml-pretty
                --output ${CMAKE_BINARY_DIR}/coverage_${COV_TARGET_NAME}.xml
                --print-summary
            COMMAND ${CMAKE_COMMAND} -E echo "Coverage XML report generated at: ${CMAKE_BINARY_DIR}/coverage_${COV_TARGET_NAME}.xml"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${COV_EXECUTABLE}
            COMMENT "Generating XML coverage report for ${COV_TARGET_NAME}"
        )
        
        # JSON report
        add_custom_target(coverage_json_${COV_TARGET_NAME}
            COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
            COMMAND ${CMAKE_COMMAND} -E echo "Running tests for coverage..."
            COMMAND $<TARGET_FILE:${COV_EXECUTABLE}>
            COMMAND ${CMAKE_COMMAND} -E echo "Generating JSON coverage report..."
            COMMAND ${GCOVR_PATH} --root ${CMAKE_SOURCE_DIR} ${GCOVR_EXCLUDES}
                --gcov-ignore-parse-errors
                --json --json-pretty
                --output ${CMAKE_BINARY_DIR}/coverage_${COV_TARGET_NAME}.json
                --print-summary
            COMMAND ${CMAKE_COMMAND} -E echo "Coverage JSON report generated at: ${CMAKE_BINARY_DIR}/coverage_${COV_TARGET_NAME}.json"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${COV_EXECUTABLE}
            COMMENT "Generating JSON coverage report for ${COV_TARGET_NAME}"
        )
        
        # Terminal summary report
        add_custom_target(coverage_summary_${COV_TARGET_NAME}
            COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
            COMMAND ${CMAKE_COMMAND} -E echo "Running tests for coverage..."
            COMMAND $<TARGET_FILE:${COV_EXECUTABLE}>
            COMMAND ${CMAKE_COMMAND} -E echo ""
            COMMAND ${CMAKE_COMMAND} -E echo "=== Coverage Summary for ${COV_TARGET_NAME} ==="
            COMMAND ${GCOVR_PATH} --root ${CMAKE_SOURCE_DIR} ${GCOVR_EXCLUDES}
                --gcov-ignore-parse-errors
                --print-summary
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${COV_EXECUTABLE}
            COMMENT "Generating terminal coverage summary for ${COV_TARGET_NAME}"
        )
        
        # Detailed terminal report
        add_custom_target(coverage_report_${COV_TARGET_NAME}
            COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
            COMMAND ${CMAKE_COMMAND} -E echo "Running tests for coverage..."
            COMMAND $<TARGET_FILE:${COV_EXECUTABLE}>
            COMMAND ${CMAKE_COMMAND} -E echo ""
            COMMAND ${CMAKE_COMMAND} -E echo "=== Detailed Coverage Report for ${COV_TARGET_NAME} ==="
            COMMAND ${GCOVR_PATH} --root ${CMAKE_SOURCE_DIR} ${GCOVR_EXCLUDES}
                --gcov-ignore-parse-errors
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${COV_EXECUTABLE}
            COMMENT "Generating detailed terminal coverage report for ${COV_TARGET_NAME}"
        )
    endif()
    
    # Main coverage target (uses gcovr if available, otherwise lcov)
    if(GCOVR_PATH)
        add_custom_target(${COV_COVERAGE_NAME}
            DEPENDS coverage_gcovr_html_${COV_TARGET_NAME}
        )
    elseif(LCOV_PATH AND GENHTML_PATH)
        add_custom_target(${COV_COVERAGE_NAME}
            DEPENDS coverage_html_${COV_TARGET_NAME}
        )
    endif()
    
endfunction()
