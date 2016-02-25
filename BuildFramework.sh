#!/bin/bash

XCODEBUILD=`which xcodebuild`
if [ -z "$XCODEBUILD" ]; then
echo "xcodebuild tool not found"
exit 127
fi

$XCODEBUILD -project Seeds.xcodeproj -configuration Release -target SeedsSDK -sdk iphoneos clean build
$XCODEBUILD -project Seeds.xcodeproj -configuration Release -target SeedsSDK -sdk iphonesimulator clean build
mkdir -p build/Framework/Device
cp -a build/Release-iphoneos/SeedsSDK.framework build/Framework/Device
mkdir -p build/Framework/Simulator
cp -a build/Release-iphonesimulator/SeedsSDK.framework build/Framework/Simulator
open build/Framework
