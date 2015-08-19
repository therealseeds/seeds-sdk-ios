#!/bin/bash

XCODEBUILD=`which xcodebuild`
if [ -z "$XCODEBUILD" ]; then
    echo "xcodebuild tool not found"
    exit 127
fi

rm -rf build
mkdir build
$XCODEBUILD -project Seeds.xcodeproj -configuration Release -scheme SeedsLibrary -sdk iphoneos -derivedDataPath build
$XCODEBUILD -project Seeds.xcodeproj -configuration Release -scheme SeedsLibrary -sdk iphonesimulator -derivedDataPath build
$XCODEBUILD -project Seeds.xcodeproj -configuration Release -scheme SeedsResources -sdk macosx -derivedDataPath build
mkdir -p build/Unity3D/Assets/Plugins/iOS
cp -a build/Build/Products/Release/SeedsResources.bundle build/Unity3D/Assets/Plugins/iOS
lipo -create build/Build/Products/Release-iphoneos/libSeedsLibrary.a build/Build/Products/Release-iphonesimulator/libSeedsLibrary.a -output build/Unity3D/Assets/Plugins/iOS/libSeedsLibrary.a
cp SDK/Seeds.h build/Unity3D/Assets/Plugins/iOS
cp SDK/SeedsInAppMessageDelegate.h build/Unity3D/Assets/Plugins/iOS
open build/Unity3D
