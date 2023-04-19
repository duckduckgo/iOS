#!/bin/sh

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

echo "Checking metadata length..."

# Set the metadata path based on the first command-line argument, or use the default path if no argument is given
if [ -z "$1" ]; then
	METADATA_PATH="${base_dir}/fastlane/metadata"
else 
	METADATA_PATH="$1"
fi

# Define the allowed lengths for each metadata file
ALLOWED_LENGTHS="name.txt:30 subtitle.txt:30 promotional_text.txt:170 description.txt:4000 keywords.txt:100 release_notes.txt:4000"

# Create an empty file to hold any errors
ALL_ERRORS=$(mktemp)

# Check the length of each metadata file
find "$METADATA_PATH" -type f -name "*.txt" | while IFS= read -r FILEPATH; do
	FILENAME=$(basename "$FILEPATH")
	ALLOWED_LENGTH=$(echo "$ALLOWED_LENGTHS" | grep -o "$FILENAME:[0-9]*" | cut -d ':' -f 2)
	if [ -z "$ALLOWED_LENGTH" ]; then
		continue
	fi

	LENGTH=$(LC_CTYPE=en_US.UTF-8 wc -m < "$FILEPATH" | xargs)
	if [ "$LENGTH" -gt "$ALLOWED_LENGTH" ]; then
		ERROR="error: $FILEPATH length exceeded ($LENGTH/$ALLOWED_LENGTH)"
		printf '%s\n' "$ERROR" >> "$ALL_ERRORS"
	fi
done

# Print any errors and exit with a non-zero status if there are errors
if [ -s "$ALL_ERRORS" ]; then
	echo "💥 Error: Oops, some fields are too long:"
	cat "$ALL_ERRORS"
	rm "$ALL_ERRORS"
	exit 1
else
	echo "✅ All strings fit, hooray!"
	rm "$ALL_ERRORS"
fi