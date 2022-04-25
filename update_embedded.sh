#!/bin/sh

TEMP_FILENAME="embedded_new_file"
TEMP_ETAG_FILENAME="embedded_new_etag"

rm -f "$TEMP_FILENAME"
rm -f "$TEMP_ETAG_FILENAME"

# parameters: url, provider file path, data file path
performUpdate() {
  FILE_URL=$1
  PROVIDER_PATH=$2
  DATA_PATH=$3
  printf "Processing: %s\n" "${FILE_URL}"

  if test ! -f "$DATA_PATH"; then
    printf "Error: Missing %s\n" "${DATA_PATH}"
    exit 1
  fi

  if test ! -f "$PROVIDER_PATH"; then
    printf "Error: Missing %s\n" "${PROVIDER_PATH}"
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

performUpdate 'https://staticcdn.duckduckgo.com/trackerblocking/v2.1/apple-tds.json' 'Core/AppTrackerDataSetProvider.swift' 'Core/trackerData.json'
performUpdate 'https://staticcdn.duckduckgo.com/trackerblocking/config/v2/ios-config.json' 'Core/AppPrivacyConfigurationDataProvider.swift' 'Core/ios-config.json'
