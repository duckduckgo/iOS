#!/bin/sh

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

echo "Updating..."
"${script_dir}/loc_update.sh"

echo "Exporting..."
loc_path="${script_dir}/assets/loc"
rm -r "$loc_path"
xcodebuild -exportLocalizations -project "${base_dir}/DuckDuckGo-iOS.xcodeproj" -localizationPath "$loc_path" -sdk iphoneos -exportLanguage en
open "${loc_path}/en.xcloc/Localized Contents"
