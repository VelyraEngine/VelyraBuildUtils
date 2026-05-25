# Include guard
if (DEFINED _COMPILER_FLAGS_CMAKE_ALREADY_INCLUDED)
    return()
endif ()
set(_COMPILER_FLAGS_CMAKE_ALREADY_INCLUDED TRUE)

# Compiler specific flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # Flag for recursive macro expansion
    add_compile_options(/Zc:preprocessor)
    add_compile_options(/wd4251) # Prevents warning for DLL boundaries, fix it later
endif ()
