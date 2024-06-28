#!/bin/zsh

# Common constants and functions for use in UI test scripts

## Constants

project_root=$(realpath $(dirname $0)/..)
derived_data_path="$project_root"/DerivedData
app_location="$derived_data_path/Build/Products/Debug-iphonesimulator/DuckDuckGo.app"
device_uuid_path="$derived_data_path/device_uuid.txt"

echo
echo "Configuration: "
echo "project_root: $project_root"
echo "derived_data_path: $derived_data_path"
echo "app_location: $app_location"
echo "device_uuid_path: $device_uuid_path"

## Functions

fail() {
    echo "‼️ $1"
    echo
    exit 1
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "‼️ Error: $1 is not installed. See source of this script for information."
        echo
        exit 1
    fi
}


