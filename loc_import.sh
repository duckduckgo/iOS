#!/bin/sh

for dir in $1/*; do
  echo
  locale=`basename "$dir"`
  targetLocale=$(echo $locale | cut -f1 -d-)

  if test -f "$dir/en.xliff"; then
    echo "Processing $locale xliff"

    if [ "$locale" != "$targetLocale" ];
    then
      echo "Changing locale from '$locale' to '$targetLocale'"
      sed -i '.bak' "s/target-language=\"$locale\"/target-language=\"$targetLocale\"/" "$dir/en.xliff"
      rm "$dir/en.xliff.bak"
    fi

    echo "Importing $dir/en.xliff..."
    xcodebuild -importLocalizations -project DuckDuckGo.xcodeproj -localizationPath "$dir/en.xliff"
  elif test -f "$dir/Localizable.stringsdict"; then
    echo "Processing $locale stringsdict"
    cp "$dir/Localizable.stringsdict" "DuckDuckGo/$targetLocale.lproj/"
  fi

done
