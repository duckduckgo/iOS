### Set up environment for UI testing

## Constants

derived_data_path=DerivedData
app_location=$derived_data_path/Build/Products/Debug-iphonesimulator/DuckDuckGo.app

# The simulator command requires the hyphens
target_device="iPhone-15"
target_os="iOS-17-2"

## Functions

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "⚠️  Error: $1 is not installed. See source of this script for information."
        echo
        exit 1
    fi
}

## Main Script

echo
echo "ℹ️  Checking environment for UI testing with maestro"

check_command xcodebuild
check_command xcrun

## If maestro is not installed run the following commands
#
# curl -Ls "https://get.maestro.mobile.dev" | bash
# brew tap facebook/fb
# brew install facebook/fb/idb-companion
#
check_command maestro

echo "✅ Expected commands available"
echo

echo "ℹ️  Removing previously created $derived_data_path"
rm -rf $derived_data_path

echo "⏲️  Building the app"
set -o pipefail && xcodebuild -scheme "DuckDuckGo" -destination "platform=iOS Simulator,name=iPhone 15,OS=17.2" -derivedDataPath "$derived_data_path" -skipPackagePluginValidation -skipMacroValidation ONLY_ACTIVE_ARCH=NO | tee xcodebuild.log
if [ $? -ne 0 ]; then
    echo "⚠️ Unable to build app into $derived_data_path"
    exit 1
fi

echo "ℹ️  Closing all simulators"
killall Simulator

device_uuid=$(xcrun simctl create "$target_device $target_os (maestro)" "com.apple.CoreSimulator.SimDeviceType.$target_device" "com.apple.CoreSimulator.SimRuntime.$target_os")
if [ $? -ne 0 ]; then
    echo "⚠️ Unable to create simulator for $target_device and $target_os"
    exit 1
fi

echo "📱 Using simulator $device_uuid"

xcrun simctl boot $device_uuid
if [ $? -ne 0 ]; then
    echo "⚠️ Unable to boot simulator"
    exit 1
fi

open -a Simulator

xcrun simctl install booted $app_location
if [ $? -ne 0 ]; then
    echo "⚠️ Unable to install app from $app_location"
    exit 1
fi

echo "$device_uuid" > $derived_data_path/device_uuid.txt

echo
echo "✅  Environment ready for running UI tests. Please see scripts/run_ui_tests.sh"
echo
