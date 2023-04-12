#!/bin/sh

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

if [ -z "$1" ]; then
	echo 'Usage: ./set_version.sh <version>'
	echo 'Example: ./set_version.sh 7.100.1'
	echo Current version: "$(cut -d' ' -f3 < "${base_dir}"/Configuration/Version.xcconfig)"
	exit 1
fi

printf "MARKETING_VERSION = %s\n" "$1" > "${base_dir}/Configuration/Version.xcconfig"
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:0:DefaultValue $1" "${base_dir}/DuckDuckGo/Settings.bundle/Root.plist"
