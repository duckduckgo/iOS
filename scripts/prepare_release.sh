#!/bin/bash

set -eo pipefail

mute=">/dev/null 2>&1"
version="$1"
latest_build_number=$(agvtool what-version -terse)
next_build_number=$((latest_build_number + 1))
release_branch_parent="main"
tag=${version}
hotfix_branch_parent="tags/${tag}"

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
	  $ $(basename "$0") <version> <branch-with-fix> [-h] [-v]
	  Current version: $(cut -d' ' -f3 < "${base_dir}/Configuration/Version.xcconfig")

	Options:
	  -h         Make hotfix release. Requires the version to be the one to hotfix, and a branch with the fix as the second parameter
	  -v         Enable verbose mode

	EOF

	die "${reason}"
}

read_command_line_arguments() {
	number_of_arguments="$#"

	local regexp="^[0-9]+(\.[0-9]+)*$"
	if [[ ! "$1" =~ $regexp ]]; then
		print_usage_and_exit "💥 Error: Wrong app version specified"
	fi

	if [[ "$#" -ne 1 ]]; then 
		if [[ "$2" == -* ]]; then
			shift 1
		else
			fix_branch=$2
			shift 2
		fi
	fi

	release_branch_prefix="release"

	while getopts 'hv' option; do
		case "${option}" in
			h) # hotfix
				is_hotfix=1
				release_branch_prefix="hotfix"
				;;
			v) # verbose
				mute=
				;;
			*)
				print_usage_and_exit "💥 Error: Unknown option '${option}'"
				;;
		esac
	done

	release_branch="${release_branch_prefix}/${version}"
	build_branch="${release_branch}-build-0"

	if release_branch_exists; then 
		is_subsequent_release=1
		build_branch="${release_branch}-build-${next_build_number}"
	fi

	shift $((OPTIND-1))

	if [[ $is_hotfix ]]; then
		if [[ $number_of_arguments -ne 3 ]]; then
			print_usage_and_exit "💥 Error: Wrong number of arguments. Did you specify a fix branch?"
		fi

		version_to_hotfix=${version}
		IFS='.' read -ra arrIN <<< "$version"
		patch_number=$((arrIN[2] + 1))
		version="${arrIN[0]}.${arrIN[1]}.$patch_number"
	fi
}

release_branch_exists() {
    if git show-ref --verify --quiet "refs/heads/$release_branch"; then
        return 0
    else
        return 1
    fi
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
	if git show-ref --quiet "refs/heads/${build_branch}"; then
		die "💥 Error: Branch ${build_branch} already exists"
	fi
}

assert_hotfix_tag_exists() {
	printf '%s' "Checking tag to hotfix ... "

	# Make sure tag is available locally if it exists
	eval git fetch origin "+refs/tags/${tag}:refs/tags/${tag}" "$mute"

	if [[ $(git tag -l "$version_to_hotfix" "$mute") ]]; then
	    echo "✅"
	else
	    die "💥 Error: Tag ${version_to_hotfix} does not exist"
	fi
}

create_release_and_build_branches() {
	if [[ ${is_hotfix} ]]; then
		printf '%s' "Creating hotfix branch ... "
		eval git checkout "${hotfix_branch_parent}" "$mute"
	else
		printf '%s' "Creating release branch ... "
		eval git checkout ${release_branch_parent} "$mute"
		eval git pull "$mute"
	fi
	eval git checkout -b "${release_branch}" --track "origin/${release_branch}" "$mute"
	eval git checkout -b "${build_branch}" --track "origin/${build_branch}" "$mute"
	echo "✅"
}

create_build_branch() {
	printf '%s' "Creating build branch ... "
	eval git checkout "${release_branch}" "$mute"
	eval git pull "$mute"
	eval git checkout -b "${build_branch}" --track "origin/${build_branch}" "$mute"
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

merge_fix_branch_if_necessary() {
	if [[ ! $is_hotfix ]]; then
		return
	fi

	printf '%s' "Merging fix branch ... "
	eval git checkout "${fix_branch}" "$mute"
	eval git pull "$mute"

	eval git checkout "${build_branch}" "$mute"
	eval git merge "${fix_branch}" "$mute"
	echo "✅"
}

create_pull_request() {
	printf '%s' "Creating PR ... "
	if [[ ! $is_subsequent_release ]]; then
		eval git push -u origin "${release_branch}" "$mute"
	fi
	eval git push -u origin "${build_branch}" "$mute"
	eval gh pr create --title \"Release "${version}-${next_build_number}"\" --base "${release_branch}" --assignee @me "$mute" --body-file "${script_dir}/assets/prepare-release-description"
	eval gh pr view --web "$mute"
	echo "✅"
}

main() {
	assert_ios_directory
	assert_fastlane_installed
	assert_gh_installed_and_authenticated

	read_command_line_arguments "$@"

	stash

	if [[ $is_subsequent_release ]]; then 
		create_build_branch
	elif [[ $is_hotfix ]]; then
		assert_clean_state
		assert_hotfix_tag_exists
		create_release_and_build_branches
		update_marketing_version
	else # regular release
		assert_clean_state
		create_release_and_build_branches
		update_marketing_version
		update_embedded_files
	fi

	update_build_version

	update_release_notes
	merge_fix_branch_if_necessary

	create_pull_request
}

main "$@"