###############################################################################
# Macro to copy files from source to binary directory as part of build
#
# Usage:
# copy_resources(${TARGET} "${FILES}" ${OUT_DIR})
# TARGET: the target the copy is done for
# FILES: list of files to be copied
# OUT_DIR: directory to copy to
#
###############################################################################
macro(copy_resources TARGET FILES OUT_DIR)
    foreach(F ${FILES})
        get_filename_component(g ${F} NAME)
        add_custom_command(
            TARGET ${TARGET} PRE_BUILD
            COMMAND
            ${CMAKE_COMMAND} -E copy ${F} ${CMAKE_BINARY_DIR}/${OUT_DIR}/${g}
            DEPENDS "${FILES}")
    endforeach()
endmacro()

###############################################################################
# Macro to return a list of subdirectories for a given directory
#
# Usage:
# child_dirs(${RESULT} ${PARENT_DIR})
# RESULT: a list of all children directories, absolute paths
# PARENT_DIR: the parent directory to be listed
#
###############################################################################
macro(child_dirs RESULT PARENT_DIR)
    file(GLOB children RELATIVE ${PARENT_DIR} ${PARENT_DIR}/*)
    set(dirs "")
    foreach(child ${children})
        if(IS_DIRECTORY ${PARENT_DIR}/${child})
            list(APPEND dirs ${PARENT_DIR}/${child})
        endif()
    endforeach()
    set(${RESULT} ${dirs})
endmacro()


###############################################################################
# Macro to split a x.y.z version number into its components
#
# Usage:
# extract_version (${VERSION} MAJOR MINOR PATCH)
# VERSION: version string in form x.y.z
# MAJOR: out variable x
# MINOR: out variable y
# PATCH: out variable z
#
###############################################################################
macro(extract_version version major minor patch)
    set(VERSION_REGEX "[0-9]+\\.[0-9]+\\.[0-9]+")
    if(${version} MATCHES ${VERSION_REGEX})
        string(REGEX REPLACE "^([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1"
            ${major} "${version}")
        string(REGEX REPLACE "^[0-9]+\\.([0-9])+\\.[0-9]+" "\\1"
            ${minor} "${version}")
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+)" "\\1"
            ${patch} "${version}")
    else()
        message(FATAL_ERROR "Cannot parse version ${version}")
    endif()
endmacro()
