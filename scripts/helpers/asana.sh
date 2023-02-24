#!/bin/bash

set -eo pipefail

# Get the directory where the script is stored
asana_script_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source "$asana_script_dir/common.sh"

# Set up variables for authentication and API endpoint
endpoint="https://app.asana.com/api/1.0"

task_name="Update metadata"
in_progress_section_id="414225518901808" # 'In progress' section within 'iOS App Board'
pr_section_id="414413334607374" # 'PR' section within 'iOS App Board'

metadata_output_path="./metadata.zip"

#
# Retrieves the Asana task ID for the 'Update metadata' task, 
# downloads the metadata.zip attachment associated with that task
#
asana_get_metadata_zip() {
	local attachment_id
	local attachment_url
	
	if [[ -z "$task_id" ]]; then
		_asana_get_task_id
	fi

	printf '%s' "Getting attached zip for '$task_name' task ... "
	attachment_id=$(_asana_get_zip_attachment_id)

	if [[ -z "$attachment_id" ]]; then
  		echo "💥 Error: Attachment not found in the: $task_name task"
		return 1
	fi

	attachment_url=$(_asana_get_zip_download_url)
	_asana_get_metadata_zip

	if [[ ! -e "$metadata_output_path" ]]; then
		echo "💥 Error: Failed to download an attachment"
		return 1
	else 
		echo "✅"
	fi
}

#
# Retrieves the Asana task ID for the 'Update metadata' task, 
# downloads the metadata.zip attachment associated with that task
#
asana_get_task_url() {
	if [[ -z "$task_id" ]]; then
		_asana_get_task_id
	fi

	printf '%s' "Getting url for '$task_name' task ... "

	task_url="$(curl -s "$endpoint/tasks/$task_id" \
		-H "Authorization: Bearer $asana_personal_access_token" \
		| jq ".data.permalink_url" \
		| tr -d '"')"

	if [[ -z "$task_url" ]]; then
		echo "💥 Error: Task URL not found."
    	return 1
	else 
		echo "✅"
	fi

	echo "$task_url"
}

#
# Updates the specified task by posting a comment with a PR link 
# and then moves the task to the PR section (if no errors).
#
# Parameters:
#   comment - The comment to post on the task.
#   is_error - A boolean value indicating whether an error occurred during the task update.
#
asana_update_task() {
	local comment="$1"
	local is_error="$2"
	local task_id

	echo
	printf '%s' "Getting '$task_name' task ... "
	task_id=$(_asana_get_update_metadata_task_id)

	if [[ -z "$task_id" ]]; then
		die "💥 Error: Task not found"
	else
		echo "✅"
	fi

	printf '%s' "Posting a comment to a task ... "
	if _asana_update_task_with_comment "$comment"; then
		echo "✅"
	else 
		die "💥 Error: Failed to post a comment"
	fi

	if [[ "$is_error" == false ]]; then
		printf '%s' "Moving task to PR section ... "
		if _asana_move_task_to_pr_section; then
			echo "✅"
		else
			die "💥 Error: Failed to move a task to PR section"
		fi
	fi
}

# Private

#
# Verify that required software is installed and fetch Asana access token
#
_asana_preflight() {
	if ! command -v jq &> /dev/null; then
		cat <<- EOF
		jq is required to update Asana tasks. Install it with:
		  $ brew install jq
		
		EOF
		die
	fi

	asana_personal_access_token="${ASANA_ACCESS_TOKEN}"
}

_asana_get_task_id() {
	printf '%s' "Getting '$task_name' task ... "
	task_id=$(_asana_get_update_metadata_task_id)

	if [[ -z "$task_id" ]]; then
		die "💥 Error: Task not found"
	else
		echo "✅"
	fi
}

_asana_get_update_metadata_task_id() {
	curl -s "$endpoint/tasks?section=$in_progress_section_id" \
    	-H "Authorization: Bearer $asana_personal_access_token" \
    	| jq ".data[] | select(.name == \"$task_name\") | .gid" \
		| tr -d '"'
}

_asana_get_zip_attachment_id() {
	curl -s "$endpoint/attachments?parent=$task_id" \
		-H "Authorization: Bearer $asana_personal_access_token" \
		| jq ".data[] | select(.name | test(\".zip$\")) | .gid" \
		| tr -d '"'
}

_asana_get_zip_download_url() {
	curl -s "$endpoint/attachments/$attachment_id" \
		-H "Authorization: Bearer $asana_personal_access_token" \
		| jq ".data.download_url" \
		| tr -d '"'
}

_asana_get_metadata_zip() {
	curl -s "$attachment_url" \
		-o "$metadata_output_path"
}

_asana_update_task_with_comment() {
	return_code="$(curl -s "$endpoint/tasks/$task_id/stories" \
		-H "Authorization: Bearer $asana_personal_access_token" \
		-H 'Content-Type: application/json' \
		--write-out '%{http_code}' \
		--output /dev/null \
		-X POST \
		-d '{"data":{"text":"'"${1}"'", "is_pinned":true}}')"

	[[ ${return_code} -eq 201 ]]
}

_asana_move_task_to_pr_section() {
	return_code="$(curl -s "$endpoint/sections/$pr_section_id/addTask" \
		-H "Authorization: Bearer $asana_personal_access_token" \
		-H 'Content-Type: application/json' \
		--write-out '%{http_code}' \
		--output /dev/null \
		-X POST \
		-d '{"data":{"task":"'"${task_id}"'"}}')"

	[[ ${return_code} -eq 200 ]]
}

_asana_preflight