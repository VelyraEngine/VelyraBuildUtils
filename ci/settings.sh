# Sourced by the other CI scripts so configure, build and test agree on the build folder and type.
#   VL_BUILD_DIR   Defaults to build-ci, so it does not touch the build folders of your IDE
#   VL_BUILD_TYPE  Defaults to Debug
build_dir="${VL_BUILD_DIR:-build-ci}"
build_type="${VL_BUILD_TYPE:-Debug}"
