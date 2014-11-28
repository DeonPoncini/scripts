# -*- cmake -*-

# - Find GLM
# Find the GLM includes and library
# This module defines
#  GLM_INCLUDE_DIR, where to find glm.hpp, etc.
#  GLM_FOUND, If false, do not try to use GLFW.

find_path(GLM_INCLUDE_DIR glm/glm.hpp
    /usr/local/include
    /usr/include)

if(GLM_INCLUDE_DIR)
    set(GLM_FOUND "YES")
else(GLM_INCLUDE_DIR)
    set(GLM_FOUND "NO")
endif(GLM_INCLUDE_DIR)

if(GLM_FOUND)
    message(STATUS "Found glm")
else(GLM_FOUND)
    message(FATAL_ERROR "Could not find glm")
endif(GLM_FOUND)

mark_as_advanced(GLM_INCLUDE_DIR)
