#!/bin/bash

set -eo pipefail

mute=">/dev/null 2>&1"
is_subsequent_release=0
base_branch="main"
build_number=0

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

#
# Output passed arguments to stderr and exit.
#
die() {
	echo ""
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
	  $ $(basename "$0") <version | hotfix-branch> [-v]
	  Current version: $(cut -d' ' -f3 < "${base_dir}/Configuration/Version.xcconfig")

	Options:
	  -v         Enable verbose mode

	Arguments:
	  <version | hotfix-branch>   Specify either a version number or a hotfix branch name.

	EOF

	die "${reason}"
}

stash() {
	printf '%s' "Stashing your changes ... "
	eval git stash "$mute"
	echo "✅"
}

read_command_line_arguments() {
	local input="$1"
	local version_regexp="^[0-9]+(\.[0-9]+)*$"

	if [ -z "$input" ]; then
		print_usage_and_exit "💥 Error: Missing argument"
	fi

	shift 1

	while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -v)
                mute=
                ;;
            -s|--subsequent)
                is_subsequent_release=1
                ;;
            *)
                print_usage_and_exit "💥 Error: Unknown option '$1'"
                ;;
        esac
        shift
    done

	if [[ $input =~ $version_regexp ]]; then
		process_release "$input"
	else
		process_hotfix "$input"
	fi
}

process_release() { # expected input e.g. "1.72.0"
	version="$1"
	release_branch="release/${version}"

	echo "Processing version number: $version"

	if [[ "$is_subsequent_release" -eq 1 ]]; then
		# check if the release branch exists (it must exist for a subsequent release)
		if ! release_branch_exists; then
			die "💥 Error: Release branch does not exist for a subsequent release!"
		fi
		base_branch="$release_branch"
	else
		# check if the release branch does NOT exist (it must NOT exist for an initial release)
		if release_branch_exists; then
			die "💥 Error: Release branch already exists for an initial release!"
		fi
	fi
}

process_hotfix() { # expected input e.g. "hotfix/1.72.1"
	version=$(echo "$1" | cut -d '/' -f 2)
	release_branch="$1"
	base_branch="$1"
	is_hotfix=1

	echo "Processing hotfix branch name: $release_branch"

	if ! release_branch_exists; then
		die "💥 Error: Hotfix branch ${release_branch} does not exist. It should be created before you run this script."
	fi
}

checkout_base_branch() {
	eval git checkout "${base_branch}" "$mute"
	eval git pull "$mute"
}

release_branch_exists() {
	if git show-ref --verify --quiet "refs/heads/${release_branch}"; then
		return 0
	else
		return 1
	fi
}

create_release_branch() {
	printf '%s' "Creating release branch ... "

	if git show-ref --quiet "refs/heads/${release_branch}"; then
		die "💥 Error: Branch ${release_branch} already exists"
	fi

	eval git checkout -b "${release_branch}" "$mute"
	if ! eval git push -u origin "${release_branch}" "$mute"; then
		die "💥 Error: Failed to push ${release_branch} to origin"
	fi
	echo "✅"
}

create_build_branch() {
	printf '%s' "Creating build branch ... "

	local temp_file
	local latest_build_number

	temp_file=$(mktemp)
	bundle exec fastlane latest_build_number_for_version version:"$version" file_name:"$temp_file"
	latest_build_number="$(<"$temp_file")"
	build_number=$((latest_build_number + 1))
	build_branch="${release_branch}-build-${build_number}"

	if git show-ref --quiet "refs/heads/${build_branch}"; then
		die "💥 Error: Branch ${build_branch} already exists"
	fi

	eval git checkout -b "${build_branch}" "$mute"
	if ! eval git push -u origin "${build_branch}" "$mute"; then
		die "💥 Error: Failed to push ${build_branch} to origin"
	fi

	echo "✅"
}

update_marketing_version() {
	printf '%s' "Setting app version ... "

	"$script_dir/set_version.sh" "${version}"
	git add "${base_dir}/Configuration/Version.xcconfig" \
		"${base_dir}/DuckDuckGo/Settings.bundle/Root.plist"
	eval git commit --allow-empty -m \"Update version number\" "$mute"
	echo "✅"
}

update_build_version() {
	echo "Setting build version ..."
	(cd "$base_dir" && bundle exec fastlane increment_build_number_for_version version:"${version}")
	git add "${base_dir}/DuckDuckGo-iOS.xcodeproj/project.pbxproj"
	if [[ "$(git diff --cached)" ]]; then
		eval git commit --allow-empty -m \"Update build number\" "$mute"
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
	eval git push origin "${build_branch}" "$mute"
	eval gh pr create --title \"Release "${version}-${build_number}"\" --base "${release_branch}" --label \"Merge triggers release\" --assignee @me "$mute" --body-file "${script_dir}/assets/prepare-release-description"
	eval gh pr view --web "$mute"
	echo "✅"
}

main() {
	assert_ios_directory
	assert_fastlane_installed
	assert_gh_installed_and_authenticated

	stash
	read_command_line_arguments "$@"
	checkout_base_branch

	if [[ "$is_subsequent_release" -eq 1 ]]; then
		create_build_branch
	elif [[ $is_hotfix ]]; then
		create_build_branch
		update_marketing_version
	else # regular release
		create_release_branch
		create_build_branch
		update_marketing_version
		update_embedded_files
	fi

	update_build_version
	update_release_notes
	create_pull_request
}

main "$@"
