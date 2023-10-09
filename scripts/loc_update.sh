#!/bin/sh

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

# Add target sub-directories here when needed
set -- "${base_dir}/DuckDuckGo" "${base_dir}/Widgets" "${base_dir}/PacketTunnelProvider"

for dir in "$@"; do
	echo "Processing ${dir}"
	find "${dir}/" -name "*.swift" -print0 | xargs -0 xcrun extractLocStrings -o "${dir}/en.lproj"
	iconv -f UTF-16 -t UTF8 "${dir}/en.lproj/Localizable.strings" > "${dir}/en.lproj/Localizable-UTF8.strings"
	mv "${dir}/en.lproj/Localizable-UTF8.strings" "${dir}/en.lproj/Localizable.strings"
done
