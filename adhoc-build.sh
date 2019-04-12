
NAME="$1/DuckDuckGo-$2`date "+%Y-%m-%d-%H-%M"`.ipa"
echo Building $NAME
echo

fastlane gym --export_method ad-hoc --scheme DuckDuckGo -n DuckDuckGo-$2`date "+%Y-%m-%d-%H-%M"`.ipa -o $1

