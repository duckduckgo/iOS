#!/bin/sh

TEMP_FILENAME="embedded_new_file"
TEMP_ETAG_FILENAME="embedded_new_etag"

rm -f "$TEMP_FILENAME"
rm -f "$TEMP_ETAG_FILENAME"

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

performUpdate() {
	if [ "$#" -ne 3 ]; then
		printf "Function expects 3 paramters: url, provider file path and data file path\n"
		exit 1
	fi

	FILE_URL=$1
	PROVIDER_PATH=$2
	DATA_PATH=$3
	printf "Processing: %s\n" "${FILE_URL}"

	if test ! -f "$DATA_PATH"; then
		printf "Error: %s does not exist\n" "${DATA_PATH}"
		exit 1
	fi

	if test ! -f "$PROVIDER_PATH"; then
		printf "Error: %s does not exist\n" "${PROVIDER_PATH}"
		exit 1
	fi

	OLD_ETAG=$(grep 'public static let embeddedDataETag' "${PROVIDER_PATH}" | awk -F '\\\\"' '{print $2}')
	OLD_SHA=$(grep 'public static let embeddedDataSHA' "${PROVIDER_PATH}" | awk -F '"' '{print $2}')

	printf "Existing ETag: %s\n" "${OLD_ETAG}"
	printf "Existing SHA256: %s\n" "${OLD_SHA}"

	curl -o "$TEMP_FILENAME" -H "If-None-Match: \"${OLD_ETAG}\"" --etag-save "$TEMP_ETAG_FILENAME" "${FILE_URL}"

	if test -f $TEMP_FILENAME; then
		NEW_ETAG=$(< "$TEMP_ETAG_FILENAME" awk -F '"' '{print $2}')
		NEW_SHA=$(shasum -a 256 "$TEMP_FILENAME" | awk -F ' ' '{print $1}')

		printf "New ETag: %s\n" "$NEW_ETAG"
		printf "New SHA256: %s\n" "$NEW_SHA"

		sed -i '' "s/$OLD_ETAG/$NEW_ETAG/g" "${PROVIDER_PATH}"
		sed -i '' "s/$OLD_SHA/$NEW_SHA/g" "${PROVIDER_PATH}"

		cp "$TEMP_FILENAME" "$DATA_PATH"

		printf 'Files updated\n\n'
	else
		printf 'Nothing to update\n\n'
	fi

	rm -f "$TEMP_FILENAME"
	rm -f "$TEMP_ETAG_FILENAME"
}

# The following URLs shall match the ones in AppURLs.swift. Danger checks that the URLs match on every PR. If the code changes, the regex that Danger uses may need an update.
performUpdate 'https://staticcdn.duckduckgo.com/trackerblocking/v5/current/ios-tds.json' "${base_dir}/Core/AppTrackerDataSetProvider.swift" "${base_dir}/Core/trackerData.json"
performUpdate 'https://staticcdn.duckduckgo.com/trackerblocking/config/v4/ios-config.json' "${base_dir}/Core/AppPrivacyConfigurationDataProvider.swift" "${base_dir}/Core/ios-config.json"
