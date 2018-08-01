carthage bootstrap --platform iOS --cache-builds;
xcrun simctl uninstall booted com.duckduckgo.mobile.ios;
xcodebuild test -project DuckDuckGo.xcodeproj -scheme AtbIntegrationTests CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -destination 'platform=iOS Simulator,name=iPhone 6s';
