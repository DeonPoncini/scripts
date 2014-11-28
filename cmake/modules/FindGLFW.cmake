# -*- cmake -*-

# - Find GLFW
# Find the GLFW includes and library
# This module defines
#  GLFW_INCLUDE_DIR, where to find glfw3.h, etc.
#  GLFW_LIBRARIES, the libraries needed to use GLFW.
#  GLFW_FOUND, If false, do not try to use GLFW.

find_path(GLFW_INCLUDE_DIR GLFW/glfw3.h
    /usr/local/include
    /usr/include)

find_library(GLFW_LIBRARY
    NAMES libglfw.so
    PATHS /usr/lib /usr/local/lib)

set(GLFW_LIBRARIES
    ${GLFW_LIBRARY})

if(GLFW_INCLUDE_DIR AND GLFW_LIBRARIES)
    set(GLFW_FOUND "YES")
else(GLFW_INCLUDE_DIR AND GLFW_LIBRARIES)
    set(GLFW_FOUND "NO")
endif(GLFW_INCLUDE_DIR AND GLFW_LIBRARIES)

if(GLFW_FOUND)
    message(STATUS "Found glfw: ${GLFW_LIBRARIES}")
else(GLFW_FOUND)
    message(FATAL_ERROR "Could not find glfw")
endif(GLFW_FOUND)

mark_as_advanced(GLFW_INCLUDE_DIR)
