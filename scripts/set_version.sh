#!/bin/sh

if [ -z "$1" ]; then
   echo Usage: ./set_version.sh NUMBER
   echo Example: ./set_version.sh 7.100.1
   echo Current version: `cat Configuration/Version.xcconfig | cut -d' ' -f3`
   exit 1
fi

echo "MARKETING_VERSION = $1\n" > Configuration/Version.xcconfig
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:0:DefaultValue $1" DuckDuckGo/Settings.bundle/Root.plist
