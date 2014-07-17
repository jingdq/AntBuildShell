#!/bin/bash
#Author:tanglong Email:tanglong@cmcm.com
# build Android application package (.apk) from the command line using the SDK tools 

echo "\n =========check env=======\n"
export PATH=$PATH:$ANDROID_SDK/tools/:$ANDROID_SDK/platform-tools/:$ANDROID_SDK/build-tools/19.1.0
echo $PATH

echo "\n =========check aapt======\n"
aapt  

echo "\n =========checkout source code=====\n"
BUILD_ROOT=`pwd`
BUILD_SOURCE_NAME=source
BUILD_APK_NAME=FullscreenActivity-release.apk

RELEASE_APK_PATH=$BUILD_ROOT/release_apks
PUBLISH_APK_PATH=$BUILD_ROOT/publish_apks

BUILD_TOOL_ANT_PATH=$ANDROID_SDK/tools/ant/

BUILD_BIN_PATH=bin
BUILD_BIN_CLASSES_PATH=classes

SOURCE_DIR=$BUILD_ROOT/$BUILD_SOURCE_NAME

if [ ! -d $RELEASE_APK_PATH ]; then
   mkdir $RELEASE_APK_PATH
fi

if [ ! -d $SOURCE_DIR ]; then
   mkdir $SOURCE_DIR
   cd $SOURCE_DIR
   svn checkout https://github.com/clarck/AutoBuildProject/trunk . 
else 
   cd $SOURCE_DIR
   svn update
fi

if [ ! -d $SOURCE_DIR/$BUILD_BIN_CLASSES_PATH ]; then
   mkdir $SOURCE_DIR/$BUILD_BIN_CLASSES_PATH
else 
   rm -r $SOURCE_DIR/$BUILD_BIN_CLASSES_PATH/*
fi

rev=`svn info | grep Revision | awk '{print $2}'`
date=`date +%Y-%m-%d_%H-%M-%S`

echo "\n =======check ant env========"
ls $BUILD_TOOL_ANT_PATH

echo "\n =======ant build==========="
android update project -p . --target android-19
ant clean & ant release

echo "\n =======copy apk==========="
if [ -f $SOURCE_DIR/$BUILD_BIN_PATH/$BUILD_APK_NAME ]; then
  cp $SOURCE_DIR/$BUILD_BIN_PATH/$BUILD_APK_NAME $RELEASE_APK_PATH
  echo "copy release apk successfull!"
else 
  echo "release apk is not exists!"
fi

echo "\n ========remove source code======"
rm -r $SOURCE_DIR

echo "\n ========public apk============="
if [ ! -d $PUBLISH_APK_PATH ]; then
   mkdir $PUBLISH_APK_PATH
fi

md5value=`md5sum $RELEASE_APK_PATH/$BUILD_APK_NAME | awk '{print $1}'`
echo md5value >> $PUBLISH_APK_PATH/apk.md5
echo "md5: $md5value"
echo "svn: $rev"
echo "date: $date"

mv $RELEASE_APK_PATH/$BUILD_APK_NAME $PUBLISH_APK_PATH/${date}_${rev}_release.apk
rm -r $RELEASE_APK_PATH

echo "publish successfull !"


