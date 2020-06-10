# DuckDuckGo iOS


We are excited to engage the community in development!


## We are hiring!
DuckDuckGo is growing fast and we continue to expand our fully distributed team. We embrace diverse perspectives, and seek out passionate, self-motivated people, committed to our shared vision of raising the standard of trust online. If you are a senior software engineer capable in either iOS or Android, visit our [careers](https://duckduckgo.com/hiring/#open) page to find out more about our openings!

## Building

### Submodules
We use submodules, so you will need to bring them in to the project in order to build and run it:

Run `git submodule update --init --recursive`

### Developer details
If you're not part of the DuckDuckGo team, you should provide your Apple developer account id, app id, and group id prefix in an `ExternalDeveloper.xcconfig` file. To do that:

 1. Run `cp Configuration/DuckDuckGoDeveloper.xcconfig Configuration/ExternalDeveloper.xcconfig`
 2. Edit `Configuration/ExternalDeveloper.xcconfig` and change the values of all fields
 3. Clean and rebuild the project

### Dependencies
We use Carthage for dependency management. If you don't have Carthage installed refer to [Installing Carthage](https://github.com/Carthage/Carthage#installing-carthage).

Run `carthage bootstrap --platform iOS` before opening the project in Xcode

You can also run the unit tests to do the above and ensure everything seems in order: `./run_tests.sh`

### SwiftLint
We use [SwifLint](https://github.com/realm/SwiftLint) for enforcing Swift style and conventions, so you'll need to [install it](https://github.com/realm/SwiftLint#installation).

### Fonts
We use Proxima Nova fonts which are proprietary and cannot be committed to source control, see [fonts](https://github.com/duckduckgo/iOS/tree/develop/fonts/licensed). 

## Debugging

### Instruments

We have Custom Instruments tool to help visualize and track events that happen during runtime.

In order to run it:
1. Build a Debug version and install it on Simulator/Device.
2. Select Instruments target and run it on a Mac. New instance of Instruments app will be run that has a grayed out icon indicating that it works in debug mode with custom instruments attached.
3. Select 'DDG Trace' template or setup a custom one by importing 'DDG Timeline' instrument from Library .
4. Start recording.

See [Instruments Developer Help](https://help.apple.com/instruments/developer/mac/current/) for reference how to create custom instruments.

## Contribute

Please refer to [contributing](CONTRIBUTING.md).

## Discuss

Contact us at https://duckduckgo.com/feedback if you have feedback, questions or want to chat. You can also use the feedback form embedded within our Mobile App - to do so please navigate to Settings and select "Send Feedback".

## License
DuckDuckGo is distributed under the Apache 2.0 [license](https://github.com/duckduckgo/ios/blob/master/LICENSE).


