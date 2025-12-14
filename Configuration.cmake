include(${CMAKE_CURRENT_LIST_DIR}/PrettyColors.cmake)

# Toolchain Information
message(STATUS "${Yellow}C Compiler: ${CMAKE_C_COMPILER}${ColorReset}")
message(STATUS "${Yellow}C++ Compiler: ${CMAKE_CXX_COMPILER}${ColorReset}")
message(STATUS "${Yellow}Linker: ${CMAKE_LINKER}${ColorReset}")
message(STATUS "${Yellow}CMake Generator: ${CMAKE_GENERATOR}${ColorReset}")

# C and C++ information
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
message(STATUS "${Yellow}C++ Version: ${CMAKE_CXX_STANDARD}${ColorReset}")

# Configure ccache (if found)
find_program(CCACHE_PROGRAM ccache)
if (CCACHE_PROGRAM)
    message(STATUS "${Green}Found ccache: ${CCACHE_PROGRAM}${ColorReset}")
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
else ()
    message(STATUS "${Red}ccache not found; not using a compiler launcher. Consider configuring CCache${ColorReset}")
endif ()

# Check if mold linker is available
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    find_program(MOLD_PATH mold)
    if (MOLD_PATH)
        message(STATUS "${Green}Found mold linker: ${MOLD_PATH}${ColorReset}")
        add_link_options("-fuse-ld=mold")
    else()
        message(STATUS "${Red}mold linker not found, falling back to default system linker. Consider installing mold${ColorReset}")
    endif()
endif ()

# check build type
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "${Green}Building in Debug Mode${ColorReset}")
    add_compile_definitions(VL_DEBUG)
else()
    message(STATUS "Building in ${CMAKE_BUILD_TYPE} Mode")
endif()

if (BUILD_TESTING)
    message(STATUS "Building tests")
    enable_testing()
    add_compile_definitions(VL_TESTING)

endif ()