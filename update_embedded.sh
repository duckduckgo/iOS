#!/bin/sh

TEMP_FILENAME="embedded_new_file"
TEMP_ETAG_FILENAME="embedded_new_etag"

rm -f "$TEMP_FILENAME"
rm -f "$TEMP_ETAG_FILENAME"

# parameters: url, provider file path, data file path
function performUpdate() {
  FILE_URL=$1
  PROVIDER_PATH=$2
  DATA_PATH=$3
  echo "Processing: ${FILE_URL}"

  OLD_ETAG=$(cat ${PROVIDER_PATH} | grep 'public static let embeddedDataETag' | awk -F '\\\\"' '{print $2}')
  OLD_SHA=$(cat ${PROVIDER_PATH} | grep 'public static let embeddedDataSHA' | awk -F '"' '{print $2}')

  echo "Existing ETag: ${OLD_ETAG}"
  echo "Existing SHA256: ${OLD_SHA}"

  curl -o $TEMP_FILENAME -H "If-None-Match: \"${OLD_ETAG}\"" --etag-save $TEMP_ETAG_FILENAME "${FILE_URL}"

  if test -f $TEMP_FILENAME; then
    NEW_ETAG=$(cat $TEMP_ETAG_FILENAME | awk -F '"' '{print $2}')
    NEW_SHA=$(shasum -a 256 $TEMP_FILENAME | awk -F ' ' '{print $1}')

    echo "New ETag: $NEW_ETAG"
    echo "New SHA256: $NEW_SHA"

    sed -i '' "s/$OLD_ETAG/$NEW_ETAG/g" ${PROVIDER_PATH}
    sed -i '' "s/$OLD_SHA/$NEW_SHA/g" ${PROVIDER_PATH}

    cp $TEMP_FILENAME $DATA_PATH

    echo "Files updated\n"
  else
    echo "Nothing to update\n"
  fi

  rm -f "$TEMP_FILENAME"
  rm -f "$TEMP_ETAG_FILENAME"
}

performUpdate 'https://staticcdn.duckduckgo.com/trackerblocking/v2.1/apple-tds.json' 'Core/AppTrackerDataSetProvider.swift' 'Core/trackerData.json'
performUpdate 'https://staticcdn.duckduckgo.com/trackerblocking/config/v2/ios-config.json' 'Core/AppPrivacyConfigurationDataProvider.swift' 'Core/ios-config.json'
