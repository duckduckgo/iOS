#!/bin/sh

echo "Updating..."
./loc_update.sh

echo "Exporting..."
rm -r loc
xcodebuild -exportLocalizations -project DuckDuckGo.xcodeproj -localizationPath loc -exportLanguage en
open "loc/en.xcloc/Localized Contents"
