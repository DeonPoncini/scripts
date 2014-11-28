# -*- cmake -*-

# - Find Assimp
# Find the Assimp includes and library
# This module defines
#  ASSIMP_INCLUDE_DIR, where to find Importer.hpp, etc.
#  ASSIMP_LIBRARIES, the libraries needed to use Assimp.
#  ASSIMP_FOUND, If false, do not try to use Assimp.

find_path(ASSIMP_INCLUDE_DIR assimp/Importer.hpp
    /usr/local/include
    /usr/include)

find_library(ASSIMP_LIBRARY
    NAMES libassimp.so
    PATHS /usr/lib /usr/local/lib)

set(ASSIMP_LIBRARIES
    ${ASSIMP_LIBRARY})

if(ASSIMP_INCLUDE_DIR AND ASSIMP_LIBRARIES)
    set(ASSIMP_FOUND "YES")
else(ASSIMP_INCLUDE_DIR AND ASSIMP_LIBRARIES)
    set(ASSIMP_FOUND "NO")
endif(ASSIMP_INCLUDE_DIR AND ASSIMP_LIBRARIES)

if(ASSIMP_FOUND)
    message(STATUS "Found assimp: ${ASSIMP_LIBRARIES}")
else(ASSIMP_FOUND)
    message(FATAL_ERROR "Could not find assimp")
endif(ASSIMP_FOUND)

mark_as_advanced(ASSIMP_INCLUDE_DIR)
