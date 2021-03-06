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
# RES:  list of absolute paths to resource files
# JARS: paths to Java JAR files that need to be installed
# APKS: list of Android APK files that need to be installed
# JAR_PATHS: directories containg jars that wish to be exposed to other
#       projects
# JAVA_INCLUDES: directories containing java files that wish to be exposed to
#       other projects
# PYTHON_INCLUDES: directories containing python files that wish to be exposed
#       to other projects
# PATH: directory to any build time scripts that are useful for other projects
#       to be able to run
# DATA: directory to any data that is useful during build time for other
#       projects
#
###############################################################################
function(export_project)
    set(options )
    set(oneValueArgs NAME VERSION PATH DATA)
    set(multiValueArgs INCLUDES LIBS ARCHIVES BINS RES JARS APKS JAR_PATHS
        JAVA_INCLUDES PYTHON_INCLUDES)
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
    if (export_targets)
        file(WRITE ${export_config} "include(${export_file})\n")
    else()
        file(WRITE ${export_config} "\n")
    endif()
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
    # install resources
    if(EXP_RES)
        install(
            FILES ${EXP_RES}
            DESTINATION ${CMAKE_INSTALL_PREFIX}/res
        )
    endif()
    # install jars
    if(EXP_JARS)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_JARS \"\")\n")
        foreach(j ${EXP_JARS})
            file(APPEND ${export_config}
                "list(APPEND ${EXP_NAME_uc}_JARS ${j})\n")
        endforeach()

        install(
            FILES
                ${EXP_JARS}
            DESTINATION
                ${CMAKE_INSTALL_PREFIX}/jar
        )
    endif()
    # install APKs
    if(EXP_APKS)
        install(
            FILES
                ${EXP_APKS}
            DESTINATION
                ${CMAKE_INSTALL_PREFIX}/apk
        )
    endif()
    # export jar files
    if (EXP_JAR_PATHS)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_JAR_PATHS \"\")\n")
        foreach(j ${EXP_JAR_PATHS})
            file(APPEND ${export_config}
                "list(APPEND ${EXP_NAME_uc}_JAR_PATHS ${j})\n")
        endforeach()
    endif()
    # export java includes
    if (EXP_JAVA_INCLUDES)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_JAVA_INCLUDE_DIRS \"\")\n")
        foreach(j ${EXP_JAVA_INCLUDES})
            file(APPEND ${export_config}
                "list(APPEND ${EXP_NAME_uc}_JAVA_INCLUDE_DIRS ${j})\n")
        endforeach()
    endif()
    # export python includes
    if (EXP_PYTHON_INCLUDES)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_PYTHON_INCLUDE_DIRS \"\")\n")
        foreach(j ${EXP_PYTHON_INCLUDES})
            file(APPEND ${export_config}
                "list(APPEND ${EXP_NAME_uc}_PYTHON_INCLUDE_DIRS ${j})\n")
        endforeach()
    endif()
    if (EXP_PATH)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_PATH ${EXP_PATH})\n")
    endif()
    if (EXP_DATA)
        file(APPEND ${export_config} "set(${EXP_NAME_uc}_DATA ${EXP_DATA})\n")
    endif()

    # write the version file
    include(CMakePackageConfigHelpers)
    write_basic_package_version_file(
        "${export_location}/${EXP_NAME}ConfigVersion.cmake"
        VERSION ${EXP_VERSION}
        COMPATIBILITY AnyNewerVersion
    )

    # export all targets
    if (export_targets)
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
    endif()
endfunction()
