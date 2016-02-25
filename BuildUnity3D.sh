#!/bin/bash

XCODEBUILD=`which xcodebuild`
if [ -z "$XCODEBUILD" ]; then
    echo "xcodebuild tool not found"
    exit 127
fi

$XCODEBUILD -project Seeds.xcodeproj -configuration Release -target SeedsLibrary -sdk iphoneos clean build
$XCODEBUILD -project Seeds.xcodeproj -configuration Release -target SeedsLibrary -sdk iphonesimulator clean build
$XCODEBUILD -project Seeds.xcodeproj -configuration Release -target SeedsResources -sdk macosx clean build
mkdir -p build/Unity3D/Assets/Plugins/iOS
cp -a build/Release/SeedsResources.bundle build/Unity3D/Assets/Plugins/iOS
lipo -create build/Release-iphoneos/libSeedsLibrary.a build/Release-iphonesimulator/libSeedsLibrary.a -output build/Unity3D/Assets/Plugins/iOS/libSeedsLibrary.a
cp SDK/Seeds.h build/Unity3D/Assets/Plugins/iOS
cp SDK/SeedsInAppMessageDelegate.h build/Unity3D/Assets/Plugins/iOS
open build/Unity3D
