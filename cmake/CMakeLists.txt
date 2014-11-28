cmake_minimum_required(VERSION 2.8)

# import cmake
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH} $ENV{PROJECT_SCRIPT_DIR}/cmake/modules")

# set C++ flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

# import the generated cmake file
add_subdirectory($ENV{PROJECT_SYSTEM_DIR} $ENV{PROJECT_BUILD_DIR}/system)
