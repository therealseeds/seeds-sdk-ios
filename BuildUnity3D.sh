#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

XCODEBUILD=`which xcodebuild`
UNITY_IOS_PLUGINS_PATH=build/Unity3D/Assets/Plugins/iOS

if [ -z "$XCODEBUILD" ]; then
    echo "xcodebuild tool not found"
    exit 127
fi

$XCODEBUILD -project Seeds.xcodeproj -configuration Release -target SeedsLibrary -sdk iphoneos clean build
$XCODEBUILD -project Seeds.xcodeproj -configuration Release -target SeedsLibrary -sdk iphonesimulator clean build
$XCODEBUILD -project Seeds.xcodeproj -configuration Release -target SeedsResources -sdk macosx clean build
mkdir -p $UNITY_IOS_PLUGINS_PATH
cp -a build/Release/SeedsResources.bundle $UNITY_IOS_PLUGINS_PATH
lipo -create build/Release-iphoneos/libSeedsLibrary.a build/Release-iphonesimulator/libSeedsLibrary.a -output $UNITY_IOS_PLUGINS_PATH/libSeedsLibrary.a
cp SDK/Seeds.h $UNITY_IOS_PLUGINS_PATH
cp SDK/SeedsInAppMessageDelegate.h $UNITY_IOS_PLUGINS_PATH

if [ "${NOT_INTERACTIVE+1}" ]; then
  # Probably called from deploy.sh form Unity SDK
  :
else
  open build/Unity3D
fi
