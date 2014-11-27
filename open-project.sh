#!/bin/bash

# check for project name
if [ -z ${PROJECT_NAME} ] ; then
    echo "PROJECT_NAME not defined, please export PROJECT_NAME"
    return
fi

# Get script path
export SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

# set up the root for all projects
export PROJECT_ROOT=$(dirname ${SCRIPT_PATH})

# check the user settings are set
source ${SCRIPT_PATH}/include/common.sh
source ${SCRIPT_PATH}/user/user-check.sh
check_user_vars
if [ $? != 0 ] ; then
    echo "User setup not complete"
    return
fi

echo "Opening project ${PROJECT_NAME}"

# find out how deep the project root is
PROJECT_ROOT_DEPTH=$(path_depth $PROJECT_ROOT)

# check out the manifest repos to list the projects
echo "Updating project list..."
clone_or_pull ${MANIFEST_GIT} ${PROJECT_ROOT} ${MANIFEST_DIR}

# check if the project name is found inside the manifest directory
export PROJECT_MANIFEST=${PROJECT_ROOT}/${MANIFEST_DIR}/${PROJECT_NAME}.xml
if [ ! -e $PROJECT_MANIFEST ] ; then
    echo "Project ${PROJECT_NAME} not found"
    return
fi

# export the common system directories
ARTIFACT_DIR=${PROJECT_ROOT}/_artifact
export PROJECT_ARTIFACT_ROOT=${ARTIFACT_DIR}/${PROJECT_NAME}
# store manifest metadata
export PROJECT_MANIFEST_DIR=${PROJECT_ROOT}/${MANIFEST_DIR}
export MANIFEST_ARTIFACT_ROOT=${ARTIFACT_DIR}/${MANIFEST_DIR}
make_dir $MANIFEST_ARTIFACT_ROOT

export PROJECT_SCRIPT_DIR=${SCRIPT_PATH}

# set the artifact directories
export PROJECT_BUILD_DIR=${PROJECT_ARTIFACT_ROOT}/build
export PROJECT_CODEGEN_DIR=${PROJECT_ARTIFACT_ROOT}/codegen
export PROJECT_DATA_DIR=${PROJECT_ARTIFACT_ROOT}/data
export PROJECT_INSTALL_DIR=${PROJECT_ARTIFACT_ROOT}/install
export PROJECT_SYSTEM_DIR=${PROJECT_ARTIFACT_ROOT}/system
make_dir $PROJECT_BUILD_DIR
make_dir $PROJECT_CODEGEN_DIR
make_dir $PROJECT_DATA_DIR
make_dir $PROJECT_INSTALL_DIR
make_dir $PROJECT_SYSTEM_DIR

${SCRIPT_PATH}/bin/parse-manifest ${PROJECT_MANIFEST} ${PROJECT_SYSTEM_DIR} ${PROJECT_ROOT}

# setup prompt to show we have sourced the env
GIT_PROMPT_URL=https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
GIT_PROMPT_LOC=$HOME/.git-prompt.sh
if [ ! -e $GIT_PROMPT_LOC ]; then
    download $GIT_PROMPT_URL $GIT_PROMPT_LOC
fi

source $GIT_PROMPT_LOC
# find out our parent directory that is the first directory below the PROJECT_ROOT
SELECT="if [ \"\$(path_depth \$(pwd))\" -gt \"\$PROJECT_ROOT_DEPTH\" ];
then echo \"/\$(folder_at_depth \$(folder_at_depth \$(pwd) \$PROJECT_ROOT_DEPTH))\";
fi"
export PS1="\[$GREEN\][$PROJECT_NAME\[$LIGHT_BLUE\]\`${SELECT}\`\[$GREEN\]]\[$CYAN\]\$(__git_ps1)\[$LIGHT_GREEN\]$ \[$RESET_COLOR\]"

# setup the path
if [[ :$PATH: != *:"${SCRIPT_PATH}/bin":* ]] ; then
    export PATH=${SCRIPT_PATH}/bin:${PATH}
fi

echo "Project $PROJECT_NAME successfully opened"
