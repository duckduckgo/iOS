#!/bin/sh

xliffName=$2

if [ $# -ne 2 ]; then
    xliffName="en.xliff"
fi

for dir in $1/*; do
  echo processing $dir
  locale=`basename "$dir"`
  targetLocale=$(echo $locale | cut -f1 -d-)

  if test -f "$dir/$xliffName"; then
    echo "Processing $locale xliff"

    if [ "$locale" != "$targetLocale" ];
    then
      echo "Changing locale from '$locale' to '$targetLocale'"
      sed -i '.bak' "s/target-language=\"$locale\"/target-language=\"$targetLocale\"/" "$dir/$xliffName"
      rm "$dir/$xliffName.bak"
    fi

    echo "Importing $dir/$xliffName ..."
    xcodebuild -importLocalizations -project DuckDuckGo.xcodeproj -localizationPath "$dir/$xliffName"

    if [ $? -ne 0 ]; then
       echo "ERROR: Failed to import $dir/$xliffName"
       echo
       echo "Check translation folder and files then try again."
       echo
       exit 1
    fi

  elif test -f "$dir/Localizable.stringsdict"; then
    echo "Processing $locale stringsdict"
    cp "$dir/Localizable.stringsdict" "DuckDuckGo/$targetLocale.lproj/"
  else
    echo "ERROR: $xliffName or Localizable.stringsdict not found in $dir"
    echo
    exit 1
  fi

done
