
if [ -z "$1" ]; then
   echo Usage: ./adhoc_build location [suffix]
   exit 1
fi

if [ -n "$2" ]; then 
   SUFFIX="$2-"
fi

NAME="$1/DuckDuckGo-$SUFFIX`date "+%Y-%m-%d-%H-%M"`.ipa"
echo Building $NAME
echo

fastlane gym --export_method ad-hoc --scheme DuckDuckGo -n DuckDuckGo-$SUFFIX`date "+%Y-%m-%d-%H-%M"`.ipa -o $1

open $1
