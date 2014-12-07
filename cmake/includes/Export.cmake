include(CMakeParseArguments)

###############################################################################
# Function to install a projects contents, export its artifacts to be used by
# other downstream CMake projects.
#
# Listed contents are installed to CMAKE_INSTALL_PREFIX/{lib|bin|include}
# Generated <name>Config.cmake installed to CMAKE_PREFIX_PATH/lib/cmake
#
# Usage:
# function(NAME VERSION INCLUDES LIBS ARCHIVES BINS)
# NAME: single string value indicating the project name, should match the value
#       given to the project() command in the CMakeLists.txt
# VERSION: single string value in x.y.z format
# INCLUDES: list of absolute paths to include directories
# LIBS: list of target names, same values as the target named in
#       add_library(name SHARED)
# ARCHIVES: list of target names, same values as the target named in
#       add_library(name STATIC)
# BINS: list of target names, same values as the target named in
#       add_executable
#
###############################################################################
function(export_project)
    set(options )
    set(oneValueArgs NAME VERSION)
    set(multiValueArgs INCLUDES LIBS ARCHIVES BINS)
    cmake_parse_arguments(EXP "${options}" "${oneValueArgs}"
        "${multiValueArgs}" ${ARGN})

    # sanity checking
    if ("${EXP_NAME}" STREQUAL "")
        message(FATAL_ERROR "Set NAME parameter to the project name")
    endif()

    if ("${EXP_VERSION}" STREQUAL "")
        message(FATAL_ERROR "Set VERSION to the project version")
    endif()

    # extract the version
    extract_version(${EXP_VERSION} export_major export_minor export_patch)

    # generated variables
    set(export_targets )
    if(EXP_LIBS)
        list(APPEND export_targets ${EXP_LIBS})
    endif()
    if(EXP_ARCHIVES)
        list(APPEND export_targets ${EXP_ARCHIVES})
    endif()
    if(EXP_BINS)
        list(APPEND export_targets ${EXP_BINS})
    endif()
    string(TOUPPER ${EXP_NAME} EXP_NAME_uc)
    set(export_file "${CMAKE_CURRENT_BINARY_DIR}/${EXP_NAME}Targets.cmake")
    set(export_location ${CMAKE_PREFIX_PATH}/lib/cmake/${EXP_NAME})
    set(export_config ${export_location}/${EXP_NAME}Config.cmake)

    make_directory(${export_location})

    # set library properties
    foreach(f ${EXP_LIBS})
        set_property(TARGET ${f} PROPERTY VERSION ${EXP_VERSION})
        set_property(TARGET ${f} PROPERTY SOVERSION ${export_major})
        set_property(TARGET ${f} PROPERTY
            INTERFACE_${f}_MAJOR_VERSION ${export_major})
        set_property(TARGET ${f} APPEND PROPERTY
            COMPATIBLE_INTERFACE_STRING ${EXP_NAME}_MAJOR_VERSION)
    endforeach()

    # copy main items
    install(TARGETS ${export_targets} EXPORT ${EXP_NAME}Targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
        INCLUDES DESTINATION ${CMAKE_INSTALL_PREFIX}/include)

    # copy include files specifically
    install(
        DIRECTORY
            ${EXP_INCLUDES}
        DESTINATION
            ${CMAKE_INSTALL_PREFIX}
    )

    # write the config file
    file(WRITE ${export_config} "include(${export_file})\n")
    # add includes
    if (EXP_INCLUDES)
        file(APPEND ${export_config}
            "set(${EXP_NAME_uc}_INCLUDE_DIRS \"\")\n")
        foreach(f ${EXP_INCLUDES})
            file(APPEND ${export_config}
                "list(APPEND ${EXP_NAME_uc}_INCLUDE_DIRS ${f})\n")
        endforeach()
    endif()
    # add shared libraries
    if (EXP_LIBS)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_LIBRARIES \"\")\n")
        foreach(f ${EXP_LIBS})
            file(APPEND ${export_config}
                "list(APPEND ${EXP_NAME_uc}_LIBRARIES ${f})\n")
        endforeach()
    endif()
    # add static libraries
    if (EXP_ARCHIVES)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_ARCHIVES \"\")\n")
        foreach(f ${EXP_ARCHIVES})
            file(APPEND ${export_config}
                "list(APPEND ${EXP_NAME_uc}_ARCHIVES ${f})\n")
        endforeach()
    endif()
    # add binaries
    if (EXP_BINS)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_BINARIES \"\")\n")
        foreach(f ${EXP_BINS})
            file(APPEND ${export_config}
                "list(APPEND ${EXP_NAME_uc}_BINARIES ${f})\n")
        endforeach()
    endif()

    # write the version file
    include(CMakePackageConfigHelpers)
    write_basic_package_version_file(
        "${export_location}/${EXP_NAME}ConfigVersion.cmake"
        VERSION ${EXP_VERSION}
        COMPATIBILITY AnyNewerVersion
    )

    # export all targets
    message(STATUS "Exporting: ${export_targets}")
    export(TARGETS ${export_targets}
        APPEND FILE "${export_file}"
    )

    install(EXPORT ${EXP_NAME}Targets
        FILE
            ${EXP_NAME}Targets.cmake
        DESTINATION
            ${export_location}
    )

endfunction()
