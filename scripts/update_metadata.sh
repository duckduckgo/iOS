#!/bin/bash

mute=">/dev/null 2>&1"

# Get the directory where the script is stored
update_metadata_script_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

source "$update_metadata_script_dir/helpers/common.sh"

# Load Asana-related functions. This calls `_asana_preflight` which
# will check for Asana access token if needed (if asana task was passed to the script).
source "$update_metadata_script_dir/helpers/asana.sh"

source="$update_metadata_script_dir/../metadata.zip"
destination="$update_metadata_script_dir/../fastlane/metadata"

unzip_and_overwrite_metadata() {
	printf '%s' "Updating fastlane/metadata files ... "
	local tempdir
	tempdir="$(mktemp -d)"
	trap 'rm -rf "$tempdir"' EXIT
	if ! eval unzip "${source}" -d "${tempdir}" -x "__MACOSX/*" "$mute"; then
		echo
		die "💥 Error: Failed to unzip metadata file"
	fi
	if ! eval rsync -a --delete "${tempdir}"/*/ "${destination}" "$mute"; then
		echo
		die "💥 Error: Failed to overwrite metadata files"
	fi
	echo "✅"
}

setup_git_user() {
	git config --local user.email "action@github.com"
	git config --local user.name "GitHub Action"
}

commit_metadata_changes_if_needed() {
	git add fastlane/metadata
	if [[ $(git diff --cached) ]]; then
		eval git commit -m \"Update metadata\" "$mute"
		echo "✅"
	else
		printf "\nNo changes to metadata files ✅\n"
	fi
}

main() {
	asana_get_metadata_zip
	unzip_and_overwrite_metadata
	"$update_metadata_script_dir"/check_metadata_length.sh
	setup_git_user
	commit_metadata_changes_if_needed
	task_url=$(asana_get_task_url | tee /dev/tty | tail -1)
	echo "$task_url"
}