#!/bin/bash

set -eo pipefail

mute=">/dev/null 2>&1"
version="$1"
release_branch_parent="develop"
hotfix_branch_parent="main"

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

#
# Output passed arguments to stderr and exit.
#
die() {
	cat >&2 <<< "$*"
	exit 1
}

assert_ios_directory() {
	if ! realpath "." | grep -q "/iOS"; then
		die "💥 Error: Run the script from inside the iOS project"
	fi
}

assert_fastlane_installed() {
	if ! command -v bundle &> /dev/null; then
		die "💥 Error: Bundle is not installed. See: https://app.asana.com/0/1202500774821704/1203766784006610/f"
	fi

	if ! bundle show fastlane &> /dev/null; then
		die "💥 Error: Fastlane is not installed. See: https://app.asana.com/0/1202500774821704/1203766784006610/f"
	fi
}

assert_gh_installed_and_authenticated() {
	if ! command -v gh &> /dev/null; then
		die "💥 Error: GitHub CLI is not installed. See: https://app.asana.com/0/1202500774821704/1203791243007683/f"
	fi

	if ! gh auth status 2>&1 | grep -q "✓ Logged in to github.com"; then
		echo "💥 Error: GitHub CLI is not authenticated. See: https://app.asana.com/0/1202500774821704/1203791243007683/f"
	fi
}

print_usage_and_exit() {
	local reason=$1

	cat <<- EOF
	Usage:
	  $ $(basename "$0") <version> [-h] [-v]
	  Current version: $(cut -d' ' -f3 < "${base_dir}/Configuration/Version.xcconfig")

	Options:
	  -h         Make hotfix release
	  -v         Enable verbose mode

	EOF

	die "${reason}"
}

read_command_line_arguments() {
	local regexp="^[0-9]+(\.[0-9]+)*$"
	if [[ ! "$1" =~ $regexp ]]; then
		print_usage_and_exit "💥 Error: Wrong app version specified"
	fi

	shift 1

	while getopts 'hv' option; do
		case "${option}" in
			h)
				is_hotfix=1
				;;
			v)
				mute=
				;;
			*)
				print_usage_and_exit "💥 Error: Unknown option '${option}'"
				;;
		esac
	done

	shift $((OPTIND-1))

	[[ $is_hotfix ]] && branch_name="hotfix" || branch_name="release"
	release_branch="${branch_name}/${version}"
	changes_branch="${release_branch}-changes"
}

stash() {
	printf '%s' "Stashing your changes ... "
	eval git stash "$mute"
	echo "✅"
}

assert_clean_state() {
	if git show-ref --quiet "refs/heads/${release_branch}"; then
		die "💥 Error: Branch ${release_branch} already exists"
	fi
	if git show-ref --quiet "refs/heads/${changes_branch}"; then
		die "💥 Error: Branch ${changes_branch} already exists"
	fi
}

create_release_branch() {
	if [[ ${is_hotfix} ]]; then
		printf '%s' "Creating hotfix branch ... "
		eval git checkout ${hotfix_branch_parent} "$mute"
	else
		printf '%s' "Creating release branch ... "
		eval git checkout ${release_branch_parent} "$mute"
	fi
	eval git pull "$mute"
	eval git checkout -b "${release_branch}" "$mute"
	eval git checkout -b "${changes_branch}" "$mute"
	echo "✅"
}

update_marketing_version() {
	printf '%s' "Setting app version ... "
	"$script_dir/set_version.sh" "${version}"
	git add "${base_dir}/Configuration/Version.xcconfig" \
		"${base_dir}/DuckDuckGo/Settings.bundle/Root.plist"
	eval git commit -m \"Update version number\" "$mute"
	echo "✅"
}

update_build_version() {
	echo "Setting build version ..."
	local username
	username="$(git config user.email 2>&1)"
	(cd "$base_dir" && bundle exec fastlane increment_build_number_for_version version:"${version}" username:"$username")
	git add "${base_dir}/DuckDuckGo.xcodeproj/project.pbxproj"
	if [[ "$(git diff --cached)" ]]; then
		eval git commit -m \"Update build number\" "$mute"
		echo "Setting build version ... ✅"
	else
		printf "\nNo changes to build number ✅\n"
	fi
}

update_embedded_files() {
	printf '%s' "Updating embedded files ... "
	eval "$script_dir/update_embedded.sh" "$mute"
	git add "${base_dir}/Core/AppTrackerDataSetProvider.swift" \
		"${base_dir}/Core/trackerData.json" \
		"${base_dir}/Core/AppPrivacyConfigurationDataProvider.swift" \
		"${base_dir}/Core/ios-config.json"
	if [[ "$(git diff --cached)" ]]; then
		eval git commit -m \"Update embedded files\" "$mute"
		echo "✅"
	else
		printf "\nNo changes to embedded files ✅\n"
	fi
}

update_release_notes() {
	local release_notes_path="${base_dir}/fastlane/metadata/default/release_notes.txt"
	echo "Please update release notes and save the file."
	eval open -a TextEdit "${release_notes_path}" "$mute"
	read -r -p "Press \`Enter\` when you're done to continue ..."
	git add "${release_notes_path}"
	if [[ "$(git diff --cached)" ]]; then
		eval git commit -m \"Update release notes\" "$mute"
		echo "Release notes updated ✅"
	else
		echo "No changes to release notes ✅"
	fi
}

create_pull_request() {
	printf '%s' "Creating PR ... "
	eval git push origin "${release_branch}" "$mute"
	eval git push origin "${changes_branch}" "$mute"
	eval gh pr create --title \"Release "${version}"\" --base "${release_branch}" --assignee @me "$mute" --body-file "${script_dir}/assets/prepare-release-description"
	eval gh pr view --web "$mute"
	echo "✅"
}

main() {
	assert_ios_directory
	assert_fastlane_installed
	assert_gh_installed_and_authenticated
	read_command_line_arguments "$@"
	stash
	assert_clean_state
	create_release_branch
	update_marketing_version
	update_build_version
	update_embedded_files
	update_release_notes
	create_pull_request
}

main "$@"