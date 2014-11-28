# -*- cmake -*-

# - Find LodePNG
# Find the LodePNG includes and library
# This module defines
#  LODEPNG_INCLUDE_DIR, where to find lodepng.h, etc.
#  LODEPNG_LIBRARIES, the libraries needed to use LodePNG.
#  LODEPNG_FOUND, If false, do not try to use LodePNG.

find_path(LODEPNG_INCLUDE_DIR lodepng/lodepng.h
    /usr/local/include
    /usr/include)

find_library(LODEPNG_LIBRARY
    NAMES liblodepng.so
    PATHS /usr/lib /usr/local/lib)

set(LODEPNG_LIBRARIES
    ${LODEPNG_LIBRARY})

if(LODEPNG_INCLUDE_DIR AND LODEPNG_LIBRARIES)
    set(LODEPNG_FOUND "YES")
else(LODEPNG_INCLUDE_DIR AND LODEPNG_LIBRARIES)
    set(LODEPNG_FOUND "NO")
endif(LODEPNG_INCLUDE_DIR AND LODEPNG_LIBRARIES)

if(LODEPNG_FOUND)
    message(STATUS "Found lodepng: ${LODEPNG_LIBRARIES}")
else(LODEPNG_FOUND)
    message(FATAL_ERROR "Could not find lodepng")
endif(LODEPNG_FOUND)

mark_as_advanced(LODEPNG_INCLUDE_DIR)
