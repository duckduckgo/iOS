carthage bootstrap --platform iOS --cache-builds;
xcrun simctl uninstall booted com.duckduckgo.mobile.ios;
xcodebuild test -project DuckDuckGo.xcodeproj -scheme DuckDuckGo CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -destination 'platform=iOS Simulator,name=iPhone 6s';
xcrun simctl uninstall booted com.duckduckgo.mobile.ios;
xcodebuild test -project DuckDuckGo.xcodeproj -scheme IntegrationTests CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -destination 'platform=iOS Simulator,name=iPhone 6s';
