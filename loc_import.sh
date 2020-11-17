#!/bin/sh

if [ $# -ne 2 ]; then
    echo 
    echo "USAGE: ./loc_import.sh <base import directory> <xliff name>"
    echo
    echo "e.g. ./loc_import.sh ~/Downloads/my-job-name-2/ en-2.xliff"
    echo
    exit 1
fi

for dir in $1/*; do
  echo processing $dir
  locale=`basename "$dir"`
  targetLocale=$(echo $locale | cut -f1 -d-)

  if test -f "$dir/$2"; then
    echo "Processing $locale xliff"

    if [ "$locale" != "$targetLocale" ];
    then
      echo "Changing locale from '$locale' to '$targetLocale'"
      sed -i '.bak' "s/target-language=\"$locale\"/target-language=\"$targetLocale\"/" "$dir/$2"
      rm "$dir/$2.bak"
    fi

    echo "Importing $dir/$2 ..."
    xcodebuild -importLocalizations -project DuckDuckGo.xcodeproj -localizationPath "$dir/$2"

    if [ $? -ne 0 ]; then
       echo "ERROR: Failed to import $dir/$2"
       echo 
       echo "Check translation folder and files then try again."
       echo 
       exit 1
    fi 

  elif test -f "$dir/Localizable.stringsdict"; then
    echo "Processing $locale stringsdict"
    cp "$dir/Localizable.stringsdict" "DuckDuckGo/$targetLocale.lproj/"
  else
    echo "ERROR: $2 or Localizable.stringsdict not found in $dir"
    echo
    exit 1
  fi

done
