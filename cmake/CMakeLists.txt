cmake_minimum_required(VERSION 2.8)

# set up some cross compile variables
set(TOOLCHAIN_PATH "$ENV{PROJECT_SYSROOT_TOOLCHAIN_DIR}")
set(RELEASE_PATH "$ENV{PROJECT_SYSROOT_RELEASE_DIR}")
set(COMMON_PATH "${RELEASE_PATH}/common")
set(TARGET_PATH "${RELEASE_PATH}/${CROSS_TARGET}")

# set up boost
set(Boost_NO_SYSTEM_PATHS ON)
set(BOOST_ROOT ${COMMON_PATH})
set(BOOST_INCLUDEDIR ${COMMON_PATH}/include)
set(BOOST_LIBRARYDIR ${TARGET_PATH}/lib)

# import cmake
list(APPEND CMAKE_MODULE_PATH "$ENV{PROJECT_SCRIPT_DIR}/cmake/modules")

include("$ENV{PROJECT_SCRIPT_DIR}/cmake/includes/Export.cmake")
include("$ENV{PROJECT_SCRIPT_DIR}/cmake/includes/Utils.cmake")

# set C++ flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

# import the generated cmake file
add_subdirectory($ENV{PROJECT_CODEGEN_DIR} ${CMAKE_PREFIX_PATH}/build)
