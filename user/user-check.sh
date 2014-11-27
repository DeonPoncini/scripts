#!/bin/bash

###############################################################################
# This checks that all variables that need to be set by the user actually are
###############################################################################


function check_user_vars {
    # the user file is called user.sh
    # this is gitignored as its to be configured for each user
    if [ ! -e ${SCRIPT_PATH}/user/user.sh ] ; then
        echo "user.sh needs to be created"
        return -1
    fi

    source ${SCRIPT_PATH}/user/user.sh
    if [ -z ${MANIFEST_GIT} ] ; then
        echo "MANIFEST_GIT should be set to the location of the git repository to clone containing the manifest files"
        return -1
    fi
    if [ -z ${MANIFEST_DIR} ] ; then
        echo "MANIFEST_DIR should be set to the basename of the dir under ${PROJECT_ROOT} that will hold the manifest files"
        return -1
    fi
    return 0
}
