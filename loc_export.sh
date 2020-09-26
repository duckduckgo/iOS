#!/bin/sh

echo "Updating..."
./loc_update.sh

echo "Exporting..."
xcodebuild -exportLocalizations -project DuckDuckGo.xcodeproj -localizationPath loc -exportLanguage en
open loc
