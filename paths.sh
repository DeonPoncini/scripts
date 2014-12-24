#!/bin/bash

################################################################################
# paths.sh
# Set the library and run paths for executables
# $1 host type
# $2 debug or release
################################################################################

if [ -z ${PROJECT_ROOT} ] ; then
    echo "Please source open-project.sh"
    exit 1
fi

HOST="$1"
BUILD_TYPE="$2"

if [[ :$PATH: != *:"${PROJECT_INSTALL_DIR}/${BUILD_TYPE}/${HOST}/bin":* ]] ; then
    export PATH=${PROJECT_INSTALL_DIR}/${BUILD_TYPE}/${HOST}/bin:${PATH}
fi

# setup the LD_LIBRARY_PATH
if [[ :$LD_LIBRARY_PATH: != *:"${PROJECT_INSTALL_DIR}/${BUILD_TYPE}/${HOST}/lib":* ]] ; then
    export LD_LIBRARY_PATH=${PROJECT_INSTALL_DIR}/${BUILD_TYPE}/${HOST}/lib:${LD_LIBRARY_PATH}
fi
