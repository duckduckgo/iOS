# Scripts

* [assert_xcode_version.sh](#assert_xcode_versionsh-check-that-xcode-version-meets-minimum-requirement)
* [check_metadata_length.sh](#check_metadata_lengthsh-check-length-of-metadata-strings-for-app-store-connect)
* [check_version.sh](#check_versionsh-check-length-of-metadata-strings-for-app-store-connect)
* [loc_export.sh](#loc_exportsh-export-localizations-for-translation)
* [loc_import.sh](#loc_importsh-import-localizations)
* [loc_update.sh](#loc_updatesh-update-localization-strings-for-app-targets)
* [prepare_release.sh](#prepare_releasesh-automates-app-release-preparation-with-versioning-and-embedded-files)
* [set_version.sh](#set_versionsh-set-marketing-version-of-the-app)
* [update_embedded.sh](#update_embeddedsh-update-embedded-tracker-data-set-and-privacy-config)

## `assert_xcode_version.sh`: Check that Xcode version meets minimum requirement

This script reads the minimum required Xcode version specified in the `.xcode-version` file and compares it with the version returned by the `xcodebuild -version` command. If the installed Xcode version is lower than the required version, the script prints an error message and exits with a non-zero status code. If the installed Xcode version is higher than the required version, the script prints a warning message suggesting to update the `.xcode-version` file.

### Requirements

The script uses `xcodebuild` to check the currently installed version of Xcode, so a valid installation of Xcode and `xcodebuild` are required to run the script.

### Usage

This script is intended to be used as a build phase in Xcode called "Assert Xcode version". The script will be automatically executed before building the project, and if the Xcode version does not meet the minimum requirement, the build will fail with an error message.

## `check_metadata_length.sh`: Check length of metadata strings for App Store Connect

This script checks the length of metadata strings for App Store Connect before submitting an app to the App Store. It verifies that the length of the metadata strings does not exceed the allowed maximum length.

### Requirements

No 3rd party software is required to run the script. It uses built-in command line utilities.

### Usage

To check metadata correctness:

	$ ./scripts/check_metadata_length.sh

This script is used by another script `prepare_release.sh`, which creates a new app release to ensure a successful submission.

## `check_version.sh`: Check length of metadata strings for App Store Connect

This script prevents the app version number from being overridden by any external factor, such as user input or a build system. It checks whether the `MARKETING_VERSION` field is present in the `project.pbxproj` file of the Xcode project and exits with an error message if it is found.

### Requirements

No 3rd party software is required to run the script. It uses built-in command line utilities.

### Usage

This script is intended to be used as a Build Phase in Xcode called "Prevent Version Override".

## `loc_export.sh`: Export localizations for translation

This script exports localizations from the project's Xcode project file into an XLIFF file for translation. It also opens the generated XLIFF file in Xcode for review.

### Requirements

Xcode must be installed on the system.
The `loc_update.sh` script must be present in the same directory.

### Usage

To export localizations:

	$ ./scripts/loc_export.sh

The script will update the localizations with `loc_update.sh` and then export them to an XLIFF file. After the XLIFF file has been generated, it will be opened in Xcode for review. See: https://app.asana.com/0/0/1195919669085072/f for more info.

## `loc_import.sh`: Import localizations

This script imports translated localization files into the app.

### Requirements

No 3rd party software is required to run the script. It uses built-in command line utilities.

### Usage

The script takes two arguments: the path to the directory containing localization files and the base name of the translation files.

To import localization files:

	$ ./scripts/loc_import.sh /path/to/translation/files/ <name of xliff file>

See: https://app.asana.com/0/0/1195919669085073/f for more info.

## `loc_update.sh`: Update localization strings for app targets

This script updates localization strings for app targets by running `xcrun extractLocStrings` command on each Swift file in the specified target sub-directories. It then converts the extracted strings to UTF-8 format and moves them to the `en.lproj/Localizable.strings` file for each target.

### Requirements

No 3rd party software is required to run the script. It uses built-in command line utilities.

### Usage

This script is designed to be called by the `loc_export.sh` script and is intended to be used as a Build Phase in Xcode called "Update Localizable.strings". It is not intended to be used independently.

To import localization files:

	$ ./scripts/loc_import.sh /path/to/translation/files/ <name of xliff file>

See: https://app.asana.com/0/0/1195919669085073/f for more info.

## `set_version.sh`: Set marketing version of the app

This script sets the marketing version of the app by modifying `Version.xcconfig` and `Root.plist` files. It takes one argument, which is the new marketing version of the app.

### Requirements

No 3rd party software is required to run the script. It uses built-in command line utilities.

### Usage

To set the marketing version of the app, run:

	$ ./set_version.sh <version>

This script is used by another script `prepare_release.sh`, which creates a new app release with correct version number.

## `prepare_release.sh`: Automates app release preparation with versioning and embedded files

This script prepares a new app release by creating a new release branch, updating the app version number, updating build number, updating embedded files, updating release notes, and creating a pull request for review.

### Features

1. Creates a new app release with updated embedded files and release notes.
1. Allows for the creation of either a standard release or a hotfix release.
1. Automatically sets the app version and build number.
1. Updates embedded files (e.g. app tracker data and privacy configuration data).
1. Prompts for and updates release notes.
1. Creates a pull request on the default branch for review and merging.

### Requirements

* The script should be run from inside of the iOS project.
* The bundle and fastlane Ruby gems must be installed.
* The gh command-line tool (GitHub CLI) must be installed and authenticated.
* The `update_embedded.sh` script must be present in the same directory.
* The `set_version.sh` script must be present in the same directory.
* The assets directory with prepare-release-description file must be present in the same directory.

### Usage

	$ ./prepare_release.sh <version> [-h] [-v]

Where:

* `<version>`: The version number to be used for the release (e.g., 7.100.1).
* `-h`: An optional flag that indicates that this is a hotfix release. If specified, the script creates a hotfix branch instead of a release branch.
* `-v`: An optional flag that enables verbose mode.

## `update_embedded.sh`: Update embedded Tracker Data Set and Privacy Config

This script checks app's source code for ETag values of Tracker Data Set
and Privacy Config files embedded in the app, downloads new versions of the
files if they appear outdated and updates relevant entries in the source code
to reflect the metadata (ETag and SHA256 sum) of downloaded files.

It may update the following files:
* Core/ContentBlocker/AppPrivacyConfigurationDataProvider.swift
* Core/ContentBlocker/AppTrackerDataSetProvider.swift
* Core/ContentBlocker/ios-config.json
* Core/ContentBlocker/trackerData.json

### Requirements

No 3rd party software is required to run the script. It uses built-in command line utilities and curl.

### Usage

To update embedded files if needed:

    $ ./scripts/update_embedded.sh

Make sure that unit tests pass after updating files. These test cases verify
embedded data correctness:
* `EmbeddedTrackerDataTests.testWhenEmbeddedDataIsUpdatedThenUpdateSHAAndEtag`
* `AppPrivacyConfigurationTests.testWhenEmbeddedDataIsUpdatedThenUpdateSHAAndEtag`

This script is used by another script `prepare_release.sh`, which creates a new app release with updated embedded files.