option(NO_SANITIZER "Disable all sanitizers" OFF)
option(VELYRA_STRICT "Enable strict warnings" ON)

if (VELYRA_STRICT)
    message(STATUS "${Green}Enabling STRICT compilation${ColorReset}")
endif ()

# Compiler specific flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # Flag for recursive macro expansion
    add_compile_options(/Zc:preprocessor)
endif ()

# Address Sanitizer
if ((CMAKE_BUILD_TYPE STREQUAL "Debug") AND NOT NO_SANITIZER)
    message(STATUS "${Green}Enabling Sanitizers${ColorReset}")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        add_compile_options(-fno-omit-frame-pointer -g)
        add_compile_options(-fsanitize=address -static-libasan -fsanitize=undefined)

        add_link_options(-fsanitize=address -fsanitize=undefined)

    endif ()
else ()
    message(STATUS "${Red}Sanitizers Disabled${ColorReset}")
endif ()

function(velyra_target_set_compile_flags TARGET_NAME)
    message(STATUS "${Green}Setting Compiler flags for target ${TARGET_NAME}${ColorReset}")

    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        target_compile_options(${TARGET_NAME} PRIVATE
            /W4
            /permissive-
        )

        if (VELYRA_STRICT)
            target_compile_options(${TARGET_NAME} PRIVATE /WX)
        endif()

    elseif (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(${TARGET_NAME} PRIVATE
            -Wall
            -Wextra
            -Wpedantic
            -Wshadow
            -Wconversion
            -Wsign-conversion
        )

        if (VELYRA_STRICT)
            target_compile_options(${TARGET_NAME} PRIVATE -Werror)
        endif()
    endif()
endfunction()