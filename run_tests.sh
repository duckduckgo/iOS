#!/usr/bin/env bash

SIM_NAME=${DDG_SIMULATOR:-'iPhone 8'}
SCHEME=${DDG_TEST_SCHEME:-'DuckDuckGo'}

xcrun simctl uninstall booted com.duckduckgo.mobile.ios;
xcodebuild test -quiet -project DuckDuckGo.xcodeproj -scheme $SCHEME CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -destination "platform=iOS Simulator,name=$SIM_NAME";
