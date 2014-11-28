# -*- cmake -*-

# - Find SQLite3
# Find the SQLite3 includes and library
# This module defines
#  SQLITE3_INCLUDE_DIR, where to find sqlite3.h
#  SQLITE3_LIBRARIES, the libraries needed to use SQLite3.
#  SQLITE3_FOUND, If false, do not try to use SQLite3.

find_path(SQLITE3_INCLUDE_DIR sqlite3.h
    /usr/include)

find_library(SQLITE3_LIBRARY
    NAMES libsqlite3.so
    PATHS /usr/lib/x86_64-linux-gnu )

set(SQLITE3_LIBRARIES
    ${SQLITE3_LIBRARY})

if(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)
    set(SQLITE3_FOUND "YES")
else(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)
    set(SQLITE3_FOUND "NO")
endif(SQLITE3_INCLUDE_DIR AND SQLITE3_LIBRARIES)

if(SQLITE3_FOUND)
    message(STATUS "Found sqlite3: ${SQLITE3_LIBRARIES}")
else(SQLITE3_FOUND)
    message(FATAL_ERROR "Could not find sqlite3")
endif(SQLITE3_FOUND)

mark_as_advanced(SQLITE3_INCLUDE_DIR)
