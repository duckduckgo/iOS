# DuckDuckGo iOS


We are excited to engage the community in development!


## We are hiring!
We are looking for a Senior Cross-Platform engineer to help shape our mobile apps. We embrace diverse perspectives, and seek out passionate, self-motivated people, committed to our shared vision of raising the standard of trust online. Visit our [careers](https://duckduckgo.com/hiring/#open) page to find out more!

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

## Contribute

Please refer to [contributing](CONTRIBUTING.md).

## Discuss

Contact us at https://duckduckgo.com/feedback if you have feedback, questions or want to chat. You can also use the feedback form embedded within our Mobile App - to do so please navigate to Settings and select "Send Feedback".

## License
DuckDuckGo is distributed under the Apache 2.0 [license](https://github.com/duckduckgo/ios/blob/master/LICENSE).


