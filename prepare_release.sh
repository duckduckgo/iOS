#!/bin/bash

set -eo pipefail

mute=">/dev/null 2>&1"
version="$1"

#
# Output passed arguments to stderr and exit.
#
die() {
	cat >&2 <<< "$*"
	exit 1
}

print_usage_and_exit() {
    local reason=$1

    cat <<- EOF
    Usage:
      $ $(basename "$0") <version> [-h] [-v]
      Current version: $(cut -d' ' -f3 < Configuration/Version.xcconfig)

    Options:
      -h  Make hotfix release
      -v  Enable verbose mode

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
    base_branch="${branch_name}/${version}"
    changes_branch="${base_branch}-changes"
}

stash() {
    printf '%s' "Stashing your changes ... "
    eval git stash "$mute"
    echo "✅"
}

assert_clean_state() {
    if git show-ref --quiet "refs/heads/${base_branch}"; then
        die "💥 Error: Branch ${base_branch} already exists."
    fi
    if git show-ref --quiet "refs/heads/${changes_branch}"; then
        die "💥 Error: Branch ${changes_branch} already exists."
    fi
}

create_release_branch() {
    if [[ ${is_hotfix} ]]; then
	    printf '%s' "Creating hotfix branch ... "
        eval git checkout main "$mute"
    else
        printf '%s' "Creating release branch ... "
        eval git checkout develop "$mute"
    fi
    eval git pull "$mute"
    eval git checkout -b "${base_branch}" "$mute"
    eval git checkout -b "${changes_branch}" "$mute"
    echo "✅"
}

update_marketing_version() {
    printf '%s' "Setting app version ... "
    ./set_version.sh "${version}"
    git add Configuration/Version.xcconfig \
    DuckDuckGo/Settings.bundle/Root.plist
    eval git commit -m \"Update version number\" "$mute"
    echo "✅"
}

update_build_version() {
    echo "Setting build version ..."
    local username
    username="$(git config user.email 2>&1)"
    fastlane increment_build_number_for_version version:"${version}" username:"$username"
    git add DuckDuckGo.xcodeproj/project.pbxproj
    eval git commit -m \"Update build number\" "$mute"
    echo "Setting build version ... ✅"
}

update_embedded_files() {
    printf '%s' "Updating embedded files ... "
    eval ./update_embedded.sh "$mute"
    git add Core/AppTrackerDataSetProvider.swift \
    Core/trackerData.json \
    Core/AppPrivacyConfigurationDataProvider.swift \
    Core/ios-config.json
    eval git commit -m \"Update embedded files\" "$mute" || printf "\n✅ No changes to embedded files\n"
    echo "✅"
}

create_pull_request() {
    printf '%s' "Creating PR ... "
    eval git push origin "${base_branch}" "$mute"
    eval git push origin "${changes_branch}" "$mute"
    eval gh pr create --title \"Release "${version}"\" --base "${base_branch}" --assignee @me "$mute" --body-file "./scripts/assets/prepare-release-description"
    eval gh pr view --web "$mute"
    echo "✅"
}

main() {
    read_command_line_arguments "$@"
    stash
    assert_clean_state
    create_release_branch
    update_marketing_version
    update_build_version
    update_embedded_files
    create_pull_request
}

main "$@"