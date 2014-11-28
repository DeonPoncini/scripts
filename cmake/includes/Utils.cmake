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
