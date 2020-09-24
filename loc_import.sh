#!/bin/sh

for dir in $1/*; do
  if test -f "$dir/en.xliff"; then
    locale=`basename "$dir"`
    echo "Processing $locale xliff"

    targetLocale=$(echo $locale | cut -f1 -d-)
    if [ "$locale" != "$targetLoc" ]
    then
      echo "Changing locale to $targetLocale"
      sed -i "s/target-language=\"$locale\"/target-language=\"$targetLocale\"/" $dir/en.xliff
    fi

    echo "Importing $dir/en.xliff..."
    xcodebuild -importLocalizations -project DuckDuckGo.xcodeproj -localizationPath "$dir/en.xliff"
  fi

done
