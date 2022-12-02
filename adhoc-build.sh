
if [ -z "$1" ]; then
   echo Usage: ./adhoc_build location [suffix]
   exit 1
fi

if [ -n "$2" ]; then 
   SUFFIX="$2-"
fi

NAME="DuckDuckGo-$SUFFIX`date "+%Y-%m-%d-%H-%M"`"
echo Building $NAME
echo

xcodebuild -scmProvider xcode -allowProvisioningUpdates -scheme DuckDuckGo clean archive -configuration release -sdk iphoneos -archivePath $1/$NAME.xcarchive
xcodebuild -scmProvider xcode -allowProvisioningUpdates -exportArchive -archivePath $1/$NAME.xcarchive -exportOptionsPlist ./adhocExportOptions.plist -exportPath $1/$NAME

mv $1/$NAME/DuckDuckGo.ipa $1/$NAME/$NAME.ipa

open $1
