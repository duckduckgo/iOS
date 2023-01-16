#!/bin/sh

set -e

mute=">/dev/null 2>&1"
if [ "$1" == "-v" ]; then
	mute=
fi

if [ -z "$1" ]; then
    echo Usage:\ \ \ ./prepare_release.sh \<VERSION\>
    echo Example: ./prepare_release.sh 7.77.1
    echo Current version: "$(cut -d' ' -f3 < Configuration/Version.xcconfig)"
    exit 1
fi

printf '%s' "Stashing your changes ... "
eval git stash "$mute"
echo "✅"

eval git show-branch "release/$1" >/dev/null 2>&1 "$mute" && echo "💥 Error: Branch release/$1 already exists." && exit 1
eval git show-branch "release/$1-changes" >/dev/null 2>&1 "$mute" && echo "💥 Error: Branch release/$1-changes already exists." && exit 1

# Git flow start release

printf '%s' "Creating release branch ... "
eval git checkout develop "$mute"
eval git pull "$mute"
eval git checkout -b "release/$1" "$mute"
eval git checkout -b "release/$1-changes" "$mute"
echo "✅"

# Update version and build numbers

printf '%s' "Setting app version ... "
./set_version.sh "$1"
eval git add Configuration/Version.xcconfig "$mute"
eval git add DuckDuckGo/Settings.bundle/Root.plist "$mute"
eval git commit -m \""Update version number\"" "$mute"
echo "✅"

echo "Setting build version ..."
USERNAME=$(git config user.email 2>&1)
fastlane increment_build_number_for_version version:"$1" username:"$USERNAME"
eval git add DuckDuckGo.xcodeproj/project.pbxproj "$mute"
eval git commit -m \""Update build number\"" "$mute"
echo "✅ Build version has been set"

# Commit updated embedded files

printf '%s' "Updating embedded files ... "
eval ./update_embedded.sh "$mute"
eval git add Core/AppTrackerDataSetProvider.swift "$mute"
eval git add Core/trackerData.json "$mute"
eval git add Core/AppPrivacyConfigurationDataProvider.swift "$mute"
eval git add Core/ios-config.json "$mute"
eval git commit -m \""Update embedded files\"" "$mute" || echo "\n✅ No changes to embedded files"
echo "✅"

# Create a PR against release branch

printf '%s' "Creating PR ... "
eval git push origin "release/$1" "$mute"
eval git push origin "release/$1-changes" "$mute"
eval gh pr create --title \""Release $1 [TEST]\"" --base "release/$1" --body "" --assignee @me "$mute"
eval gh pr comment --body \""Make sure to update release notes, metadata and commit the changes.\"" "$mute"
eval gh pr comment --body \""Once you validate the diff, go ahead and merge this PR.\"" "$mute"
eval gh pr view --web "$mute"
echo "✅"