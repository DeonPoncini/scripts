#!/bin/bash

source ${PROJECT_SCRIPT_DIR}/include/common.sh

# download sqlite3
SQLITE_NAME=sqlite-amalgamation-3080704
DOWNLOAD_LINK=http://www.sqlite.org/2014/${SQLITE_NAME}.zip
TAR_NAME=sqlite3.zip

download_if_not_exists $DOWNLOAD_LINK $PROJECT_SYSROOT_STAGING_DIR/$TAR_NAME

# extract the archive
pushd $PROJECT_SYSROOT_STAGING_DIR >> /dev/null
if [ ! -d ${SQLITE_NAME} ] ; then
    extract $TAR_NAME .
fi

pushd $SQLITE_NAME >> /dev/null
# build for linux
clang -shared -ldl -lpthread -fpic sqlite3.c -o libsqlite3.so

# build for android
$PROJECT_SYSROOT_TOOLCHAIN_DIR/android/ndk/bin/clang -target armv7-none-linux-androideabi -DANDROID -c sqlite3.c -o sqlite3.o
$PROJECT_SYSROOT_TOOLCHAIN_DIR/android/ndk/bin/arm-linux-androideabi-ar cr libsqlite3.a sqlite3.o

# install into the release directories
make_dir $PROJECT_SYSROOT_RELEASE_DIR/common/include
make_dir $PROJECT_SYSROOT_RELEASE_DIR/linux-64/lib
make_dir $PROJECT_SYSROOT_RELEASE_DIR/android/lib

cp sqlite3.h $PROJECT_SYSROOT_RELEASE_DIR/common/include
cp libsqlite3.so $PROJECT_SYSROOT_RELEASE_DIR/linux-64/lib
cp libsqlite3.a $PROJECT_SYSROOT_RELEASE_DIR/android/lib

popd >> /dev/null
