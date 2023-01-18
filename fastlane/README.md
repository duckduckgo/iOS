fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### sync_signing

```sh
[bundle exec] fastlane sync_signing
```

Fetches and updates certificates and provisioning profiles for App Store distribution

### release_appstore

```sh
[bundle exec] fastlane release_appstore
```

Makes App Store release build and uploads it to App Store Connect

### upload_metadata

```sh
[bundle exec] fastlane upload_metadata
```

Updates App Store metadata

### release_testflight

```sh
[bundle exec] fastlane release_testflight
```

Makes App Store release build and uploads it to TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
