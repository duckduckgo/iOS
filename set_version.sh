#!/bin/sh

if [ -z "$1" ]; then
   echo Usage: "./set_version.sh <version> <buildnumber>"
   echo Example: ./set_version.sh 7.100.1 0
   echo Current version: `sed -n 1p Configuration/Version.xcconfig | cut -d' ' -f3`
   echo Current build: `sed -n 2p Configuration/Version.xcconfig | cut -d' ' -f3`
   exit 1
fi

echo "MARKETING_VERSION = $1" > Configuration/Version.xcconfig
echo "CURRENT_PROJECT_VERSION = $2\n" >> Configuration/Version.xcconfig
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:0:DefaultValue $1" DuckDuckGo/Settings.bundle/Root.plist
