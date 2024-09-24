#!/bin/zsh

### Run UI tests

source $(dirname $0)/common.sh

## Constants

run_log="$derived_data_path/run_log.txt"
app_bundle="com.duckduckgo.mobile.ios"

echo "run_log: $run_log"
echo "app_bundle: $app_bundle"

## Functions

log_message() {
    local run_log="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp: $message" >> $run_log
}

run_flow() {
	local device_uuid=$1
	local flow=$2

	echo "ℹ️ Deleting app in simulator $device_uuid"

	xcrun simctl uninstall $device_uuid $app_bundle
	if [ $? -ne 0 ]; then
		fail "Failed to uninstall the app"
	fi

	echo "ℹ️ Installing app in simulator $device_uuid"
	xcrun simctl install $device_uuid $app_location

	echo "⏲️ Starting flow $( basename $flow)"

	export MAESTRO_DRIVER_STARTUP_TIMEOUT=60000
	maestro --udid=$device_uuid test -e ONBOARDING_COMPLETED=true $flow
	if [ $? -ne 0 ]; then
		log_message $run_log "❌ FAIL: $flow"
		echo "🚨 Flow failed $flow"
	else		
		log_message $run_log "✅ PASS: $flow"
	fi
}

show_usage() {
	echo "ℹ️ Usage: $1 /path/to/flow.yaml | /path/folder/of/flows/"
	echo
	exit 1
}

## Main Script

if [ ! -f "$device_uuid_path" ]; then
	fail "Please run setup-ui-tests.sh first"
fi

if [ -z $1 ]; then
	show_usage $0
fi

if [ ! -f $1 ] && [ ! -d $1 ]; then
	echo "‼️ $1 is not a file or directory"
	show_usage $0
fi

# Run the selected tests

echo
echo "ℹ️ Running UI tests for $1"

device_uuid=$(cat $device_uuid_path)
echo "ℹ️ using device $device_uuid"

# Simulator should already be up and running from running the setup script
#  re-run the setup script with `--skip-build` to set up again 
echo "ℹ️ creating run log in $run_log"
if [ -f $run_log ]; then
	rm $run_log
fi

log_message $run_log "START"

if [ -f $1 ]; then
	run_flow $device_uuid $1
elif [ -d $1 ]; then
	for file in "$1"/*.yaml; do
		run_flow $device_uuid $file
	done
fi

log_message $run_log "END"

cat $run_log

echo 
echo "Log at $(realpath $run_log)"
echo

if grep -q "FAIL" $run_log; then
	fail "There were errors, please see check the log."
else
	echo "✅ Finished"
fi
