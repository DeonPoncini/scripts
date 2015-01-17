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

    if ("${TEST_NAME}" STREQUAL "")
        message(FATAL_ERROR "Set NAME parameter to the project name")
    endif()

    enable_testing()

    if (CMAKE_CONFIGURATION_TYPES)
        add_custom_target(check_${TEST_NAME} COMMAND ${CMAKE_CTEST_COMMAND}
            --force-new-ctest-process --output-on-failure --verbose
            --build-config "$<CONFIGURATION>")
    else()
        add_custom_target(check_${TEST_NAME} COMMAND ${CMAKE_CTEST_COMMAND}
            --force-new-ctest-process --output-on-failure --verbose)
    endif()

    if (TEST_INCLUDES)
        include_directories(${TEST_INCLUDES})
    endif()

    file(GLOB_RECURSE TEST test/*.cpp)
    add_executable(${TEST_NAME}-test EXCLUDE_FROM_ALL ${TEST})

    set_target_properties(${TEST_NAME}-test PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY test)

    if (TEST_LIBRARIES)
        target_link_libraries(${TEST_NAME}-test ${TEST_LIBRARIES})
    endif()

    add_test(${TEST_NAME}-test test/${TEST_NAME}-test)
    add_dependencies(check_${TEST_NAME} ${TEST_NAME}-test)
    add_dependencies(check check_${TEST_NAME})

endmacro()
