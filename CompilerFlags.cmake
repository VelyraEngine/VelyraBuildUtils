# Compiler specific flags
if (MSVC)
    # Flag for recursive macro expansion
    add_compile_options(/Zc:preprocessor)
endif ()