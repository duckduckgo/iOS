#!/bin/zsh

# Common constants and functions for use in UI test scripts

## Constants

project_root=$(realpath $(dirname $0)/..)
derived_data_path="$project_root"/DerivedData
app_location="$derived_data_path/Build/Products/Debug-iphonesimulator/DuckDuckGo.app"
device_uuid_path="$derived_data_path/device_uuid.txt"

# The simulator command requires the hyphens
target_device="iPhone-16"
target_os="iOS-18-2"

# Convert the target_device and target_os to the format required by the -destination flag
destination_device="${target_device//-/ }"
destination_os_version="${target_os#iOS-}"
destination_os_version="${destination_os_version//-/.}"

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

build_app() {
    if [ -d "$derived_data_path" ] && [ "$1" -eq "0" ]; then
        echo "⚠️ Removing previously created $derived_data_path"
        rm -rf $derived_data_path
    else
        echo "ℹ️ Not cleaning derived data at $derived_data_path"
    fi

    echo "⏲️ Building the app"
    set -o pipefail && xcodebuild -project "$project_root"/DuckDuckGo-iOS.xcodeproj \
                                  -scheme "iOS Browser" \
                                  -destination "platform=iOS Simulator,name=$destination_device,OS=$destination_os_version" \
                                  -derivedDataPath "$derived_data_path" \
                                  -skipPackagePluginValidation \
                                  -skipMacroValidation \
                                  ONLY_ACTIVE_ARCH=NO | tee xcodebuild.log
    if [ $? -ne 0 ]; then
        echo "‼️ Unable to build app into $derived_data_path"
        exit 1
    fi
}
