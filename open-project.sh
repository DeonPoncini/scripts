#!/bin/bash

# check for project name
if [ -z ${PROJECT_NAME} ] ; then
    echo "PROJECT_NAME not defined, please export PROJECT_NAME"
    return
fi

echo "Opening project ${PROJECT_NAME}"

# Get script path
SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

# set up the root for all projects
export PROJECT_ROOT=$(dirname ${SCRIPT_PATH})

# check the user settings are set
source ${SCRIPT_PATH}/user/user-check.sh
check_user_vars
if [ $? != 0 ] ; then
    echo "User setup not complete"
    return
fi

# find out how deep the project root is
PROJECT_ROOT_DEPTH=$(path_depth $PROJECT_ROOT)

# check out the manifest repos to list the projects
echo "Updating project list..."
MANIFEST_PATH=${PROJECT_ROOT}/${MANIFEST_DIR}
if [ ! -d ${MANIFEST_PATH} ] ; then
    pushd ${PROJECT_ROOT} >> /dev/null
    git clone ${MANIFEST_GIT} ${MANIFEST_DIR}
    popd >> /dev/null
else
    pushd ${MANIFEST_PATH} >> /dev/null
    git pull
    popd >> /dev/null
fi

# check if the project name is found inside the manifest directory
valid_project=false
for f in `find ${MANIFEST_PATH} -name *.xml` ; do
    pname=$(basename ${f})
    if [ "${PROJECT_NAME}.xml" = "$pname" ] ; then
        valid_project=true
        break
    fi
done

if [ "$valid_project" = false ] ; then
    echo "Project ${PROJECT_NAME} not found"
    return
fi

# setup prompt to show we have sourced the env
source ${SCRIPT_PATH}/include/common.sh
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
