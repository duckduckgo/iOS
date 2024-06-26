## Clean up simulators that were used for maestro.

echo
echo "Cleaning up maestro simulators.  Error messages for shutdown simulators might appear."
echo

killall Simulator 

device_id_list=$(xcrun simctl list | grep maestro | grep -oE '\([A-F0-9-]{36}\)' | tr -d '()' | sort | uniq)

if [ -z "$device_id_list" ]; then
    exit 0
fi

# Iterate over each ID
echo "$device_id_list" | while read -r device_id; do
    xcrun simctl shutdown $device_id
    xcrun simctl delete $device_id
done
