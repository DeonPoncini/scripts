#!/bin/bash

source ${PROJECT_SCRIPT_DIR}/include/common.sh

# download the toolchain
NDK_URI=http://dl.google.com/android/ndk/
NDK_VER=android-ndk-r10d
NDK_PLATFORM=linux-x86_64
NDK_NAME=${NDK_VER}-${NDK_PLATFORM}.bin
NDK_DOWNLOAD_LINK=$NDK_URI$NDK_NAME

download_if_not_exists $NDK_DOWNLOAD_LINK $PROJECT_SYSROOT_STAGING_DIR/$NDK_NAME

# unzip the toolchain
pushd $PROJECT_SYSROOT_STAGING_DIR >> /dev/null
if [ ! -d $NDK_VER ] ; then
    chmod a+x $NDK_NAME
    ./$NDK_NAME
fi

# install toolchain
ANDROID_NDK_HOME=$PROJECT_SYSROOT_TOOLCHAIN_DIR/android/ndk/
make_dir $ANDROID_NDK_HOME
$NDK_VER/build/tools/make-standalone-toolchain.sh --toolchain=arm-linux-androideabi-clang3.5 --llvm-version=3.5 --platform=android-21 --install-dir=$ANDROID_NDK_HOME

popd >> /dev/null
