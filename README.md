# DuckDuckGo iOS


We are excited to engage the community in development and will open up this project to contributions soon.

## Building

### Submodules
We only have one submodule at the moment, but because of that you will need to bring it in to the project in order to build and run it:

Run `git submodule update --init --recursive`

### Dependencies
We use Carthage for dependency management. If you don't have Carthage installed refer to [Installing Carthage](https://github.com/Carthage/Carthage#installing-carthage).

Run `carthage bootstrap --platform iOS` before opening the project in XCode

You can also run the unit tests to do the above and ensure everything seems in order: `./run_tests.sh`

### Fonts
We use Proxima Nova fonts which are proprietary and cannot be committed to source control, see [fonts](https://github.com/duckduckgo/iOS/tree/develop/fonts/licensed). 

## Discuss

Contact us at https://duckduckgo.com/feedback if you have feedback, questions or want to chat.

## License
DuckDuckGo Search & Stories is distributed under the Apache 2.0 [license](https://github.com/duckduckgo/ios/blob/master/LICENSE).
