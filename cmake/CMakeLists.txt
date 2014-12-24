cmake_minimum_required(VERSION 2.8)

# import cmake
list(APPEND CMAKE_MODULE_PATH "$ENV{PROJECT_SCRIPT_DIR}/cmake/modules")

include("$ENV{PROJECT_SCRIPT_DIR}/cmake/includes/Export.cmake")
include("$ENV{PROJECT_SCRIPT_DIR}/cmake/includes/Utils.cmake")

# set C++ flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

# import the generated cmake file
add_subdirectory($ENV{PROJECT_CODEGEN_DIR} ${CMAKE_PREFIX_PATH}/build)
