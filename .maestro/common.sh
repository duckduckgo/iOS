#!/bin/zsh

# Common constants and functions for use in UI test scripts

## Constants

derived_data_path=DerivedData
app_location=$derived_data_path/Build/Products/Debug-iphonesimulator/DuckDuckGo.app
device_uuid_path="$derived_data_path/device_uuid.txt"

## Functions

fail() {
    echo "‼️ $1"
    exit 1
}

check_is_root() {
    if [ ! -d ".maestro" ]; then
        fail "Please run from the root of the iOS directory"
    fi
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "‼️ Error: $1 is not installed. See source of this script for information."
        echo
        exit 1
    fi
}


