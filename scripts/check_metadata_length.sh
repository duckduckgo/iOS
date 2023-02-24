#!/bin/sh

echo "Checking metadata length..."

if [ -z "$1" ]; then
   METADATA_PATH="fastlane/metadata"
else 
	METADATA_PATH="$1"
fi

for FILEPATH in `find $METADATA_PATH -type f -name "*.txt"`
do
	FILENAME=`basename $FILEPATH`

	case $FILENAME in
		name.txt )
			ALLOWED_LENGTH=30
			;;

		subtitle.txt )
			ALLOWED_LENGTH=30
			;;

		promotional_text.txt )
			ALLOWED_LENGTH=170
			;;

		description.txt )
			ALLOWED_LENGTH=4000
			;;

		keywords.txt )
			ALLOWED_LENGTH=100
			;;

		release_notes.txt )
			ALLOWED_LENGTH=4000
			;;

		*)
		    continue
		    ;;
	esac

	LENGTH=`LC_CTYPE=en_US.UTF-8 wc -m < $FILEPATH | xargs`

	# echo "Checking: $FILEPATH ($LENGTH/$ALLOWED_LENGTH)"

	if ((LENGTH > ALLOWED_LENGTH)); then
		ERROR="error: $FILEPATH length exceeded ($LENGTH/$ALLOWED_LENGTH)"
		ALL_ERRORS+=("$ERROR")
	fi
done

if [ ${#ALL_ERRORS[@]} -eq 0 ]; then
    echo "✅ All strings fit, hooray!"
else
    echo "💥 Error: Oops, some fields are too long:"

    for ERROR in "${ALL_ERRORS[@]}"; do
		echo "$ERROR"
	done

	exit 1
fi

