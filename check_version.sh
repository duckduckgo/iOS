#!/bin/sh

if grep -q MARKETING_VERSION DuckDuckGo.xcodeproj/project.pbxproj
then
    echo "Error: 'MARKETING_VERSION' is present in project file."
    exit 1
fi
