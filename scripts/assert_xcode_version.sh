#!/bin/bash

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

required_xcode_version=$(<"${base_dir}"/.xcode-version)
current_xcode_version=$(xcodebuild -version | grep 'Xcode' | cut -d\  -f2)

verlte() { 
	printf '%s\n%s' "$1" "$2" | sort -C -V 
}

verlt() { 
	! verlte "$2" "$1" 
}

if verlt "$current_xcode_version" "$required_xcode_version"; then
	echo "error: You are using an outdated version of Xcode. Xcode ${required_xcode_version} is required."
	exit 1
elif [[ "$current_xcode_version" != "$required_xcode_version" ]]; then
	echo "warning: You are using a newer version of Xcode than required. If it is stable enough please consider updating the .xcode-version file to enforce it on the team."
fi