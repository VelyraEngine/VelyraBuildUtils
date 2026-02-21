include(FetchContent)
include(PrettyColors.cmake)

function(vl_include_or_fetch lib_name output_lib_root)
    if (NOT TARGET ${lib_name})
        message(STATUS "Including ${lib_name}")
        # Assume the local version is in a child folder and that the name of the library is the same as the folder name
        set(lib_root ${CMAKE_CURRENT_SOURCE_DIR}/../${lib_name})

        # Locally available?
        if (EXISTS ${lib_root})
            message(STATUS "Using local version of ${lib_name}")
            add_subdirectory(${lib_root} ${CMAKE_BINARY_DIR}/${lib_name})

        else()
            message(STATUS "Cloning ${lib_name} from git (main branch)")
            FetchContent_Declare(
                ${lib_name}
                GIT_REPOSITORY https://github.com/VelyraEngine/${lib_name}.git
                GIT_SHALLOW TRUE
                GIT_TAG main
                GIT_PROGRESS TRUE
            )
            FetchContent_MakeAvailable(${lib_name})
        endif()
        set(${output_lib_root} ${lib_root} PARENT_SCOPE)
    endif()
endfunction()

function(vl_find_or_fetch package_name url git_tag)
    include(FetchContent)

    find_package(${package_name} QUIET CONFIG)

    if (${package_name}_FOUND)
        message(STATUS "${Green}Using system-installed ${package_name}${ColorReset}")
        return()
    endif()

    message(STATUS "${Yellow}Fetching ${package_name} from ${url}, consider installing it for faster CMake configuration${ColorReset}")

    FetchContent_Declare(
        ${package_name}
        GIT_REPOSITORY ${url}
        GIT_TAG        ${git_tag}
        GIT_SHALLOW    TRUE
        GIT_PROGRESS   TRUE
    )

    FetchContent_GetProperties(${package_name})
    if(NOT ${package_name}_POPULATED)
        FetchContent_MakeAvailable(${package_name})
    endif()
endfunction()

function(vl_fetch_gtest)
    vl_find_or_fetch(
        GTest
        https://github.com/google/googletest.git
        v1.14.0
    )
endfunction()

function(vl_fetch_glfw)
    vl_find_or_fetch(
        glfw3
        https://github.com/glfw/glfw.git
        master
    )
endfunction()

function(vl_fetch_glm)
    vl_find_or_fetch(
        glm
        https://github.com/g-truc/glm.git
        master
    )
endfunction()

function(vl_fetch_fmt)
    vl_find_or_fetch(
        fmt
        https://github.com/fmtlib/fmt.git
        master
    )
endfunction()

function(vl_fetch_spdlog)
    vl_find_or_fetch(
        spdlog
        https://github.com/gabime/spdlog.git
        v1.x
    )
endfunction()

function(vl_fetch_nlohmann_json)
    vl_find_or_fetch(
        nlohmann_json
        https://github.com/nlohmann/json.git
        develop
    )
endfunction()
