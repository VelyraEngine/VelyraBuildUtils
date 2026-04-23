# Include guard
if (DEFINED _COMPILER_FLAGS_CMAKE_ALREADY_INCLUDED)
    return()
endif ()
set(_COMPILER_FLAGS_CMAKE_ALREADY_INCLUDED TRUE)

option(NO_SANITIZER "Disable all sanitizers" OFF)
option(VL_COMPILE_RELAXED "Disables all compiler checks (like conversions, unused parameters, no return values, etc" OFF)
option(VL_COMPILE_STRICT "Enable strict warnings" OFF)

if (VL_COMPILE_RELAXED)
    message(STATUS "${Red}Enabling RELAXED ompilation${ColorReset}")
elseif (VL_COMPILE_STRICT)
    message(STATUS "${Green}Enabling STRICT compilation${ColorReset}")
else ()
    message(STATUS "${Yellow}Enabling NORMAL compilation${ColorReset}")
endif ()

# Compiler specific flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # Flag for recursive macro expansion
    add_compile_options(/Zc:preprocessor)
    add_compile_options(/wd4251) # Prevents warning for DLL boundaries, fix it later
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

function(vl_configure_target TARGET_NAME)
    if (NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "${BoldRed}Target: ${TARGET_NAME} is not a target!${ColorReset}")
        return()
    endif ()
    message(STATUS "${Green}Configuring target ${TARGET_NAME}${ColorReset}")

    set_target_properties(${TARGET_NAME} PROPERTIES
        UNITY_BUILD ON
        UNITY_BUILD_BATCH_SIZE 8
        FOLDER "Velyra"
    )

    if (NOT VELYRA_COMPILE_RELAXED)
        if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            target_compile_options(${TARGET_NAME} PRIVATE
                /W4
                /permissive-
            )

            if (VELYRA_COMPILE_STRICT)
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

            if (VELYRA_COMPILE_STRICT)
                target_compile_options(${TARGET_NAME} PRIVATE -Werror)
            endif()
        endif()
    endif ()
endfunction()

function(vl_configure_test_target TARGET_NAME)
    if (NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "${BoldRed}Target: ${TARGET_NAME} is not a target!${ColorReset}")
        return()
    endif ()
    message(STATUS "${BoldGreen}Configuring test target ${TARGET_NAME}${ColorReset}")

    set_target_properties(${TARGET_NAME} PROPERTIES
        UNITY_BUILD ON
        UNITY_BUILD_BATCH_SIZE 8
        FOLDER "VelyraTest"
    )
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        target_compile_options(${TARGET_NAME} PRIVATE
            /W4
            /permissive-
        )
    elseif (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(${TARGET_NAME} PRIVATE
            -Wall
            -Wextra
            -Wpedantic
            -Wshadow
            -Wconversion
            -Wsign-conversion
        )
    endif()

    # Also configure CTest in this case
    set(CTEST_NAME "C${TARGET_NAME}")
    add_test(
        NAME ${CTEST_NAME}
        COMMAND ${PROOT} $<TARGET_FILE:${TARGET_NAME}>
    )

    set_tests_properties(${CTEST_NAME} PROPERTIES
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    )
endfunction()