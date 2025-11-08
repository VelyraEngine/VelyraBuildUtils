include(FetchContent)
include(PrettyColors.cmake)


function(include_or_fetch lib_name output_lib_root)
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
                GIT_REPOSITORY https://github.com/SyriusEngine/${lib_name}.git
                GIT_SHALLOW TRUE
                GIT_TAG main
                GIT_PROGRESS TRUE
            )
            FetchContent_MakeAvailable(${lib_name})
        endif()
        set(${output_lib_root} ${lib_root} PARENT_SCOPE)
    else()
        message(WARNING "No target ${lib_name} found!")
    endif()
endfunction()

function(fetch_lib target_name url git_tag)
    if (NOT TARGET ${target_name})
        message(STATUS "${Cyan}Fetching ${target_name}${ColorReset}")
        FetchContent_Declare(
            ${target_name}
            GIT_REPOSITORY ${url}
            GIT_TAG ${git_tag}
            GIT_PROGRESS TRUE # Show progress
            GIT_SHALLOW TRUE # Only fetch the latest commit
        )
        FetchContent_MakeAvailable(${target_name})
    endif ()
endfunction()

function(fetch_gtest)
    fetch_lib(gtest https://github.com/google/googletest.git main)
endfunction()

function(fetch_glfw)
    fetch_lib(glfw https://github.com/glfw/glfw.git master)
endfunction()

function(fetch_glm)
    fetch_lib(glm https://github.com/g-truc/glm.git bf71a834948186f4097caa076cd2663c69a10e1e)
endfunction()

function(fetch_fmt)
    fetch_lib(fmt https://github.com/fmtlib/fmt.git master)
endfunction()

function(fetch_spdlog)
    fetch_lib(spdlog git@github.com:gabime/spdlog.git master)
endfunction()