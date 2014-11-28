###############################################################################
# Macro to generate cmake tests that can be run through CTest using the
# Boost Unit Test framework
#
# Usage:
# generate_boost_unit_tests(${TESTDIR} "${INCLUDES}"
#      "${SRC}" "${LIBS}" ${EXCLUDEMAIN} ${MAINSRC})
# TESTDIR: the directory where the test source code is
# INCLUDES: all include files needed to compile test code
# SRC: all source files needed to link with test cases
# LIBS: all library dependencies needed to link test cases.
#       Note Boost Unit Tests are included by default
# EXCLUDEMAIN: If true this disables removing the main source file
# MAINSRC: Filename including the main() function so it won't be linked if it
#           is included in SRC. This defaults to main.cpp
#
###############################################################################
macro(generate_boost_unit_tests TESTDIR)

# set up the extra parameters
set(INCLUDES ${ARGV1})
set(SRC ${ARGV2})
set(LIBS ${ARGV3})
set(EXCLUDEMAIN ${ARGV4})
set(MAINSRC ${ARGV5})

# source up the test files
file(GLOB_RECURSE TEST ${TESTDIR}/*.cpp)

# strip out main.cpp if it exists
if(NOT "${EXCLUDEMAIN}")
    # set up the file to be removed
    if(NOT "${MAINSRC}")
        set(MAINSRC "${CMAKE_SOURCE_DIR}/src/main.cpp")
    endif()
    string(REGEX REPLACE ${MAINSRC} "" SRC "${SRC}")
endif()

find_package(Boost 1.48.0 COMPONENTS unit_test_framework REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})
include_directories(${INCLUDES})

enable_testing()

if(CMAKE_CONFIGURATION_TYPES)
    add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND}
        --force-new-ctest-process --output-on-failure --verbose
        --build-config "$<CONFIGURATION>")
else()
    add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND}
        --force-new-ctest-process --output-on-failure --verbose)
endif()

foreach(t ${TEST})
    # get the source name without extension
    get_filename_component(TEST_NAME ${t} NAME_WE)

    # create a test executable of that name
    set(SRCS ${t} ${SRC})
    add_executable(${TEST_NAME} EXCLUDE_FROM_ALL
        ${SRCS})

    set_target_properties(${TEST_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY test)

    # link this against the right libraries
    target_link_libraries(${TEST_NAME}
        ${Boost_LIBRARIES}
        ${LIBS})

    # add this test
    add_test(${TEST_NAME} test/${TEST_NAME})

    # depend on the check target
    add_dependencies(check ${TEST_NAME})
endforeach()

endmacro()
