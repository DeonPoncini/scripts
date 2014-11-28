# -*- cmake -*-

# - Find cpp-netlib
# Find the cpp-netlib includes and library
# This module defines
#  CPPNETLIB_INCLUDE_DIR, where to find network.hpp, etc.
#  CPPNETLIB_LIBRARIES, the libraries needed to use cpp-netlib.
#  CPPNETLIB_FOUND, If false, do not try to use cpp-netlib.

find_path(CPPNETLIB_INCLUDE_DIR boost/network.hpp
    /usr/local/include/cppnetlib
    /usr/include/cppnetlib)

find_library(CPPNETLIB_URI_LIBRARY
    NAMES libcppnetlib-uri.a
    PATHS /usr/lib /usr/local/lib)

find_library(CPPNETLIB_CLIENT_LIBRARY
    NAMES libcppnetlib-client-connections.a
    PATHS /usr/lib /usr/local/lib)

find_library(CPPNETLIB_SERVER_LIBRARY
    NAMES libcppnetlib-server-parsers.a
    PATHS /usr/lib /usr/local/lib)

set(CPPNETLIB_LIBRARIES
    ${CPPNETLIB_URI_LIBRARY}
    ${CPPNETLIB_CLIENT_LIBRARY}
    ${CPPNETLIB_SERVER_LIBRARY})

if(CPPNETLIB_INCLUDE_DIR AND CPPNETLIB_LIBRARIES)
    set(CPPNETLIB_FOUND "YES")
else(CPPNETLIB_INCLUDE_DIR AND CPPNETLIB_LIBRARIES)
    set(CPPNETLIB_FOUND "NO")
endif(CPPNETLIB_INCLUDE_DIR AND CPPNETLIB_LIBRARIES)

if(CPPNETLIB_FOUND)
    message(STATUS "Found cpp-netlib: ${CPPNETLIB_LIBRARIES}")
else(CPPNETLIB_FOUND)
    message(FATAL_ERROR "Could not find cpp-netlib")
endif(CPPNETLIB_FOUND)

mark_as_advanced(CPPNETLIB_INCLUDE_DIR)
