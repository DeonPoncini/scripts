include(CMakeParseArguments)

###############################################################################
# Macro to generate cmake tests that can be run through CTest
#
# Usage:
# add_unit_tests(NAME INCLUDES LIBRARIES)
# NAME:      the project name to build tests for
# INCLUDES:  all include files needed to compile test code
# LIBRARIES: all library dependencies needed to link test cases.
#
###############################################################################
macro(add_unit_tests)
    set(options )
    set(oneValueArgs NAME)
    set(multiValueArgs INCLUDES LIBRARIES)
    cmake_parse_arguments(TEST "${options}" "${oneValueArgs}"
        "${multiValueArgs}" ${ARGN})

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBOOST_TEST_DYN_LINK")
    find_package(Boost 1.55.0 COMPONENTS unit_test_framework REQUIRED)
    include_directories(${Boost_INCLUDE_DIRS})

    if ("${TEST_NAME}" STREQUAL "")
        message(FATAL_ERROR "Set NAME parameter to the project name")
    endif()

    if (TEST_INCLUDES)
        include_directories(${TEST_INCLUDES})
    endif()

    file(GLOB_RECURSE TEST test/*.cpp)
    add_executable(${TEST_NAME}-test EXCLUDE_FROM_ALL ${TEST})

    set_target_properties(${TEST_NAME}-test PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY test)

    target_link_libraries(${TEST_NAME}-test
        ${Boost_LIBRARIES}
        ${TEST_NAME}
        ${TEST_LIBRARIES})

    add_custom_target(check-${TEST_NAME} COMMAND
        test/${TEST_NAME}-test --log_level=all |
        $ENV{PROJECT_SCRIPT_DIR}/bin/format-tests)
    add_dependencies(${TEST_NAME}-test ${TEST_NAME})
    add_dependencies(check-${TEST_NAME} ${TEST_NAME}-test)
    add_dependencies(check check-${TEST_NAME})

endmacro()
