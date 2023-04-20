#!/bin/sh

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

if grep -q MARKETING_VERSION "${base_dir}/DuckDuckGo.xcodeproj/project.pbxproj"; then
	echo "Error: 'MARKETING_VERSION' is present in project file."
	exit 1
fi