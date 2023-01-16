#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo Usage:\ \ \ ./prepare_release.sh \<VERSION\>
    echo Example: ./prepare_release.sh 7.77.1
    echo Current version: "$(cut -d' ' -f3 < Configuration/Version.xcconfig)"
    exit 1
fi

mute=">/dev/null 2>&1"
if [ "$2" == "-v" ]; then
	mute=
fi

version="$1"

printf '%s' "Stashing your changes ... "
eval git stash "$mute"
echo "✅"

eval git show-branch "release/$1" >/dev/null 2>&1 "$mute" && echo "💥 Error: Branch release/$1 already exists." && exit 1
eval git show-branch "release/$1-changes" >/dev/null 2>&1 "$mute" && echo "💥 Error: Branch release/$1-changes already exists." && exit 1

# Git flow start release

create_release_branch() {
    printf '%s' "Creating release branch ... "
    eval git checkout develop "$mute"
    eval git pull "$mute"
    eval git checkout -b "release/${version}" "$mute"
    eval git checkout -b "release/${version}-changes" "$mute"
    echo "✅"
}

update_marketing_version() {
    printf '%s' "Setting app version ... "
    ./set_version.sh "${version}"
    eval git add Configuration/Version.xcconfig "$mute"
    eval git add DuckDuckGo/Settings.bundle/Root.plist "$mute"
    eval git commit -m \""Update version number\"" "$mute"
    echo "✅"
}

update_build_version() {
    echo "Setting build version ..."
    local username
    username="$(git config user.email 2>&1)"
    fastlane increment_build_number_for_version version:"${version}" username:"$username"
    eval git add DuckDuckGo.xcodeproj/project.pbxproj "$mute"
    eval git commit -m \""Update build number\"" "$mute"
    echo "✅ Build version has been set"
}

update_embedded_files() {
    printf '%s' "Updating embedded files ... "
    eval ./update_embedded.sh "$mute"
    eval git add Core/AppTrackerDataSetProvider.swift "$mute"
    eval git add Core/trackerData.json "$mute"
    eval git add Core/AppPrivacyConfigurationDataProvider.swift "$mute"
    eval git add Core/ios-config.json "$mute"
    eval git commit -m \""Update embedded files\"" "$mute" || printf "\n✅ No changes to embedded files\n"
    echo "✅"
}

create_pull_request() {
    printf '%s' "Creating PR ... "
    eval git push origin "release/${version}" "$mute"
    eval git push origin "release/${version}-changes" "$mute"
    eval gh pr create --title \""Release ${version} [TEST]\"" --base "release/${version}" --body "" --assignee @me "$mute" --body-file "./scripts/assets/prepare-release-description"
    eval gh pr view --web "$mute"
    echo "✅"
}

main() {
    create_release_branch
    update_marketing_version
    update_build_version
    update_embedded_files
    create_pull_request
}

main