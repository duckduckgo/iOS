#!/bin/sh

if [ -z "$1" ]; then
    echo Usage:\ \ \ ./prepare_release.sh \<VERSION\>
    echo Example: ./prepare_release.sh 7.77.1
    echo Current version: `cat Configuration/Version.xcconfig | cut -d' ' -f3`
    exit 1
fi

git stash

git show-branch release/$1 &>/dev/null && echo "Error: Branch release/$1 already exists." && exit 1
git show-branch release/$1-changes &>/dev/null && echo "Error: Branch release/$1-changes already exists." && exit 1

# Git flow start release

git checkout develop
git pull
git checkout -b release/$1
git checkout -b release/$1-changes

# Commit updated version number

./set_version.sh $1
git add Configuration/Version.xcconfig
git add DuckDuckGo/Settings.bundle/Root.plist
git commit -m "Update version number"

# Commit updated embedded files

./update_embedded.sh
git add Core/AppTrackerDataSetProvider.swift
git add Core/trackerData.json
git add Core/AppPrivacyConfigurationDataProvider.swift
git add Core/ios-config.json
git commit -m "Update embedded files"

# Create a PR against release branch # make sure GH is set up

git push origin release/$1
git push origin release/$1-changes
gh pr create --title "Release $1 [TEST]" --base release/$1 --body "" --assignee @me

#build number
#tag and push tag on merge
