### Set up environment for UI testing

## Constants
derived_data_path=DerivedData
app_location=$derived_data_path/Build/Products/Debug-iphonesimulator/DuckDuckGo.app
device_uuid_path="$derived_data_path/device_uuid.txt"

# The simulator command requires the hyphens
target_device="iPhone-15"
target_os="iOS-17-2"

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

build_app() {

    if [ -f "$derived_data_path" ]; then
        echo "⚠️ Removing previously created $derived_data_path"
        rm -rf $derived_data_path
    fi

    echo "⏲️ Building the app"
    set -o pipefail && xcodebuild -scheme "DuckDuckGo" -destination "platform=iOS Simulator,name=iPhone 15,OS=17.2" -derivedDataPath "$derived_data_path" -skipPackagePluginValidation -skipMacroValidation ONLY_ACTIVE_ARCH=NO | tee xcodebuild.log
    if [ $? -ne 0 ]; then
        echo "‼️ Unable to build app into $derived_data_path"
        exit 1
    fi

}

## Main Script

check_is_root

echo
echo "ℹ️  Checking environment for UI testing with maestro"

## If maestro is not installed run the following commands
#
# curl -Ls "https://get.maestro.mobile.dev" | bash
# brew tap facebook/fb
# brew install facebook/fb/idb-companion
#
check_command maestro
check_command xcodebuild
check_command xcrun

echo "✅ Expected commands available"
echo

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-build) skip_build=1; shift ;;
        *)
    esac
    shift
done

if [ ! -n "$skip_build" ]; then
    echo "Skipping build"
    build_app
fi

echo "ℹ️ Closing all simulators"
killall Simulator

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
