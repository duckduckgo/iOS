### Run UI tests

## Constants

derived_data_path=DerivedData
app_location=$derived_data_path/Build/Products/Debug-iphonesimulator/DuckDuckGo.app
device_uuid_path="$derived_data_path/device_uuid.txt"
run_log="$derived_data_path/run_log.txt"

app_bundle="com.duckduckgo.mobile.ios"

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
	
	# Ignore result of this for now. The only error hopefully is that there was nothing to terminate
	xcrun simctl terminate $device_uuid $app_bundle 2> /dev/null

	xcrun simctl uninstall $device_uuid $app_bundle
	if [ $? -ne 0 ]; then
		fail "Failed to uninstall the app"
	fi

	echo "ℹ️ Installing app in simulator $device_uuid"
	xcrun simctl install $device_uuid $app_location

	echo "⏲️ Starting flow $( basename $flow)"

	maestro test $flow
	if [ $? -ne 0 ]; then
		log_message $run_log "❌ FAIL: $flow"
		echo "🚨 Flow failed $flow"
	else		
		log_message $run_log "✅ PASS: $flow"
	fi
}

## Main Script

check_is_root

if [ ! -f "$device_uuid_path" ]; then
	fail "Please run setup-ui-tests.sh first"
fi

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --run-flow) 
			run_flow=1 
			run_flow_file="$2"
			if [ ! -f $run_flow_file ]; then
				fail "$run_flow_file is not a file"
			fi

			shift ;;
        --flow-location) 
			flow_location="$2"
			if [ ! -d "$flow_location" ]; then
				fail "Invalid flow location $flow_location, use --flow-location .maestro/flow_folder "
			fi
			shift ;;
        *) fail "Unknown parameter passed: $1" ;;
    esac
    shift
done

# Run the selected tests

echo
echo "ℹ️ Running UI tests"

device_uuid=$(cat $device_uuid_path)
echo "ℹ️ using device $device_uuid"

killall Simulator

xcrun simctl boot $device_uuid
if [ $? -ne 0 ]; then
    echo "‼️ Unable to boot simulator"
    exit 1
fi

open -a Simulator

echo "ℹ️ creating run log in $run_log"
rm $run_log

log_message $run_log "START"

if [ -n "$run_flow" ]; then
	if [ ! -f $run_flow_file ]; then
		fail "$run_flow_file is not a file"
	fi

	run_flow $device_uuid $run_flow_file
else
	for file in "$flow_location"/*.yaml; do
		run_flow $device_uuid $file
	done
fi

log_message $run_log "END"

cat $run_log

echo 
echo "Log at $run_log"
echo

if grep -q "FAIL" $run_log; then
	fail "There were errors, please see check the log."
else
	echo "✅ Finished"
fi
