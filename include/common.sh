#!/bin/bash

###############################################################################
# color chart
###############################################################################
BLACK='\e[0;30m'
RED='\e[0;31m'
GREEN='\e[0;32m'
BROWN='\e[0;33m'
BLUE='\e[0;34m'
PURPLE='\e[0;35m'
CYAN='\e[0;36m'
LIGHT_GRAY='\e[0;37m'
DARK_GRAY='\e[1;30m'
LIGHT_RED='\e[1;31m'
LIGHT_GREEN='\e[1;32m'
YELLOW='\e[1;33m'
LIGHT_BLUE='\e[1;34m'
LIGHT_PURPLE='\e[1;35m'
LIGHT_CYAN='\e[1;36m'
WHITE='\e[1;37m'
RESET_COLOR='\e[0m'

###############################################################################
# Check error code, exit with an error message on failure
# $1 : error code
# $2 : error message
# Usage:
#   check_error $? "make failed, aborting..."
###############################################################################
function check_error {
    if [ $1 != 0 ] ; then
        echo "$2"
        exit $1
    fi
}

###############################################################################
# Match a regular expression
# $1 : regular expression
# $2 : string to match
###############################################################################
function regexp_match {
    echo "$2" | grep -q -E -e "$1"
}

###############################################################################
# Download a file
# $1 : source URI
# $2 : destination path
###############################################################################
function download {
    # if this is HTTP, HTTPS or FTP
    if regexp_match "^(http|https|ftp):.*" "$1"; then
        wget -O $2 $1
        check_error $? "download of $1 failed, aborting..."
        return
    fi

    # if this is ssh use scp
    if regexp_match "^(ssh|[^:]+):.*" "$1"; then
        scp_src=`echo $1 | sed -e s%ssh://%%g`
        scp $scp_src $2
        check_error $? "download of $1 failed, aborting..."
        return
    fi

    # if this a file copy from file:// or /
    if regexp_match "^(file://|/).*" "$1"; then
        cp_src=`echo $1 | sed -e s%^file://%%g`
        cp -f $cp_src $2
        check_error $? "download of $1 failed, aborting..."
        return
    fi
}

###############################################################################
# How many folders deep is a path
# $1 : path to test
###############################################################################
function path_depth {
    local saveIFS=$IFS
    IFS='/'
    local parts=($1)
    IFS=$saveIFS
    echo ${#parts[@]}
}

###############################################################################
# Return a folder at a depth
# $1 : path to extract
# $2 : index to extract
###############################################################################
function folder_at_depth {
    local saveIFS=$IFS
    IFS='/'
    local parts=($1)
    IFS=$saveIFS
    echo "${parts[$2]}"
}

###############################################################################
# Make directory
# $1 : directory to make
###############################################################################
function make_dir {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

###############################################################################
# Clone a repo, or update if it already exists
# $1 git clone address
# $2 existing pathdir above the repo
# $3 name of the repository
###############################################################################
function clone_or_pull {
    if [ ! -d ${2}/${3} ] ; then
        pushd ${2} >> /dev/null
        echo "Cloning ${3}"
        git clone ${1} ${3}
        popd >> /dev/null
    else
        pushd ${2}/${3} >> /dev/null
        echo "Repository ${3}"
        git pull
        popd >> /dev/null
    fi
}
