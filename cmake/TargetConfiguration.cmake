if (DEFINED _TARGET_CONFIGURATION_CMAKE_ALREADY_INCLUDED)
    return()
endif ()
set(_TARGET_CONFIGURATION_CMAKE_ALREADY_INCLUDED TRUE)

function(vl_check_valid_target TARGET_NAME)
    if (NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "${BoldRed}Target: ${TARGET_NAME} is not a target!${ColorReset}")
    endif ()
endfunction()

function(vl_target_add_compile_definitions TARGET_NAME)
    # Build type
    target_compile_definitions(${TARGET_NAME}
        PUBLIC
        $<$<CONFIG:Debug>:VL_DEBUG>
        $<$<CONFIG:Release>:VL_RELEASE>
    )

    # Testing specific macros
    if (VL_BUILD_TESTING)
        target_compile_definitions(${TARGET_NAME} PUBLIC VL_TESTING)
    endif ()
endfunction()

function(vl_target_configure_sanitizer TARGET_NAME)
    if (VL_ENABLE_SANITIZERS)
        # TODO: Extend later to support other toolchains
        if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            target_compile_options(${TARGET_NAME} PRIVATE
                -fno-omit-frame-pointer
                -g
                -fsanitize=address
                -static-libasan
                -fsanitize=undefined
            )

            target_link_options(${TARGET_NAME} PRIVATE -fsanitize=address -fsanitize=undefined)
        endif ()
    endif ()
endfunction()

function(vl_target_configure_compiler_level TARGET_NAME)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        if (VL_COMPILER_LEVEL STREQUAL "NORMAL")
            target_compile_options(${TARGET_NAME} PRIVATE
                /W4
                /permissive-
            )
        elseif (VL_COMPILER_LEVEL STREQUAL "STRICT")
            target_compile_options(${TARGET_NAME} PRIVATE
                /W4
                /permissive-
                /WX
            )
        endif ()

    elseif (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        if (VL_COMPILER_LEVEL STREQUAL "NORMAL")
            target_compile_options(${TARGET_NAME} PRIVATE
                -Wall
                -Wextra
                -Wpedantic
                -Wshadow
                -Wconversion
                -Wsign-conversion
            )
        elseif (VL_COMPILER_LEVEL STREQUAL "STRICT")
            target_compile_options(${TARGET_NAME} PRIVATE
                -Wall
                -Wextra
                -Wpedantic
                -Wshadow
                -Wconversion
                -Wsign-conversion
                -Werror
            )
        endif ()
    endif ()
endfunction()

function(vl_configure_target TARGET_NAME)
    message(STATUS "${Green}Configuring Velyra target ${TARGET_NAME}${ColorReset}")

    vl_check_valid_target(${TARGET_NAME})
    vl_target_add_compile_definitions(${TARGET_NAME})
    vl_target_configure_sanitizer(${TARGET_NAME})
    vl_target_configure_compiler_level(${TARGET_NAME})

    set_target_properties(${TARGET_NAME} PROPERTIES
        UNITY_BUILD ${VL_ENABLE_UNITY_BUILD}
        UNITY_BUILD_BATCH_SIZE ${VL_UNITY_BUILD_BATCH_SIZE}
        FOLDER "Velyra"
    )

endfunction()

function(vl_configure_test_target TARGET_NAME)
    message(STATUS "${BoldGreen}Configuring test target ${TARGET_NAME}${ColorReset}")

    vl_check_valid_target(${TARGET_NAME})
    vl_target_add_compile_definitions(${TARGET_NAME})
    vl_target_configure_sanitizer(${TARGET_NAME})
    vl_target_configure_compiler_level(${TARGET_NAME})

    set_target_properties(${TARGET_NAME} PROPERTIES
        UNITY_BUILD ${VL_ENABLE_UNITY_BUILD}
        UNITY_BUILD_BATCH_SIZE ${VL_UNITY_BUILD_BATCH_SIZE}
        FOLDER "VelyraTest"
    )

    vl_fetch_gtest() # Fetch GTest
    target_link_libraries(${TARGET_NAME} PUBLIC GTest::gtest GTest::gtest_main)
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