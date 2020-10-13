
xcodebuild -allowProvisioningUpdates -scheme DuckDuckGo clean archive -configuration release -sdk iphoneos -archivePath ./DuckDuckGo.xcarchive
xcodebuild -allowProvisioningUpdates -exportArchive -archivePath ./DuckDuckGo.xcarchive -exportOptionsPlist ./appStoreExportOptions.plist -exportPath .

ls -la .
