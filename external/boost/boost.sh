#!/bin/bash

source ${PROJECT_SCRIPT_DIR}/include/common.sh

# download boost
BOOST_MAJOR=1
BOOST_MINOR=55
BOOST_POINT=0
BOOST_EXT=.tar.bz2

BOOST_TRIPLE_U=${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_POINT}
BOOST_TRIPLE_P=${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_POINT}
BOOST_NAME=boost_${BOOST_TRIPLE_U}
BOOST_FILE=$BOOST_NAME$BOOST_EXT

BOOST_TAR_FILE=$PROJECT_SYSROOT_STAGING_DIR/$BOOST_FILE
BOOST_EXTRACT_PATH=$PROJECT_SYSROOT_STAGING_DIR/$BOOST_NAME

# download the boost library
BOOST_DOWNLOAD_LINK="http://downloads.sourceforge.net/project/boost/boost/$BOOST_TRIPLE_P/boost_${BOOST_TRIPLE_U}${BOOST_EXT}?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost%2Ffiles%2Fboost%2F$BOOST_TRIPLE_P%2F&ts=1291326673&use_mirror=garr"

download_if_not_exists $BOOST_DOWNLOAD_LINK $BOOST_TAR_FILE

pushd $PROJECT_SYSROOT_STAGING_DIR >> /dev/null
if [ ! -d ${BOOST_NAME} ] ; then
    extract $BOOST_TAR_FILE .
fi

# build for linux-64
cp -f ${PROJECT_SCRIPT_DIR}/external/boost/linux-64/user-config.jam ${BOOST_EXTRACT_PATH}/tools/build/v2/user-config.jam
build_dir=${PROJECT_SYSROOT_BUILD_DIR}/${BOOST_NAME}_build_linux-64
pushd $BOOST_EXTRACT_PATH >> /dev/null
$BOOST_EXTRACT_PATH/bootstrap.sh --prefix=$build_dir
check_error $? "bootstrap failed, aborting..."
$BOOST_EXTRACT_PATH/b2 toolset=clang install
check_error $? "b2 install failed, aborting..."
# install the built products
cp -rf $build_dir/include/boost $PROJECT_SYSROOT_RELEASE_DIR/common/include/
cp -f $build_dir/lib/* $PROJECT_SYSROOT_RELEASE_DIR/linux-64/lib/
popd >> /dev/null

# build for android
cp -f ${PROJECT_SCRIPT_DIR}/external/boost/android/user-config.jam ${BOOST_EXTRACT_PATH}/tools/build/v2/user-config.jam
build_dir=${PROJECT_SYSROOT_BUILD_DIR}/${BOOST_NAME}_build_android
export NO_BZIP2=1
pushd $BOOST_EXTRACT_PATH >> /dev/null
patch -p1 < ${PROJECT_SCRIPT_DIR}/external/boost/android/boost.patch
check_error $? "failed to apply android patch, aborting..."
$BOOST_EXTRACT_PATH/bootstrap.sh --prefix=$build_dir
check_error $? "bootstrap failed, aborting..."
$BOOST_EXTRACT_PATH/bjam -q      \
    toolset=clang                \
    --without-context --without-coroutine --without-python \
    link=static                  \
    threading=multi              \
    install
check_error $? "b2 install failed, aborting..."
# undo the patch so boost is pristine
patch -p1 -R < ${PROJECT_SCRIPT_DIR}/external/boost/android/boost.patch
# install the built products
cp -f $build_dir/lib/* $PROJECT_SYSROOT_RELEASE_DIR/android/lib/
popd >> /dev/null
unset NO_BZIP2
