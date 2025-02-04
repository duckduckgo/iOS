#!/bin/zsh

### Set up environment for UI testing

source $(dirname $0)/common.sh

## Constants

# The simulator command requires the hyphens
target_device="iPhone-16"
target_os="iOS-18-2"

# Convert the target_device and target_os to the format required by the -destination flag
destination_device="${target_device//-/ }"
destination_os_version="${target_os#iOS-}"
destination_os_version="${destination_os_version//-/.}"

## Functions

check_maestro() {

    local command_name="maestro"
    local known_version="1.39.9"

    if command -v $command_name > /dev/null 2>&1; then
      local version_output=$($command_name -v 2>&1 | tail -n 1)

      local command_version=$(echo $version_output | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

      if [[ $command_version == $known_version ]]; then
        echo "ℹ️ maestro version matches: $command_version"
      else
        echo "‼️ maestro version does not match. Expected: $known_version, Got: $command_version"
        exit 1
      fi
    else
      echo "‼️ maestro not found install using the following commands:"
      echo
      echo "curl -Ls \"https://get.maestro.mobile.dev\" | bash"
      echo "brew tap facebook/fb"
      echo "brew install facebook/fb/idb-companion"
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

## Main Script

echo
echo "ℹ️  Checking environment for UI testing with maestro"

check_maestro
check_command xcodebuild
check_command xcrun

echo "✅ Expected commands available"
echo

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-build)
            skip_build=1 ;;
        --rebuild)
            rebuild=1 ;;
        *)
    esac
    shift
done

if [ -n "$skip_build" ]; then
    echo "Skipping build"
else
    build_app $rebuild
fi

echo "ℹ️ Closing all simulators"

killall Simulator

echo "ℹ️ Starting simulator for maestro"

device_uuid=$(xcrun simctl create "$target_device $target_os (maestro)" "com.apple.CoreSimulator.SimDeviceType.$target_device" "com.apple.CoreSimulator.SimRuntime.$target_os")
if [ $? -ne 0 ]; then
    echo "‼️ Unable to create simulator for $target_device and $target_os"
    exit 1
fi

echo "📱 Using simulator $device_uuid"

xcrun simctl boot $device_uuid
if [ $? -ne 0 ]; then
    echo "‼️ Unable to boot simulator"
    exit 1
fi

echo "ℹ️ Setting device locale to en_US"

xcrun simctl spawn $device_uuid defaults write "Apple Global Domain" AppleLanguages -array en
if [ $? -ne 0 ]; then
    echo "‼️ Unable to set preferred language"
    exit 1
fi

xcrun simctl spawn $device_uuid defaults write "Apple Global Domain" AppleLocale -string en_US
if [ $? -ne 0 ]; then
    echo "‼️ Unable to set region"
    exit 1
fi

open -a Simulator

xcrun simctl install booted $app_location
if [ $? -ne 0 ]; then
    echo "‼️ Unable to install app from $app_location"
    exit 1
fi

echo "$device_uuid" > $device_uuid_path

echo
echo "✅ Environment ready for running UI tests."
echo
