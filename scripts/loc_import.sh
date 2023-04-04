#!/bin/sh

baseName=$2

if [ $# -ne 2 ]; then
    baseName=$(basename "$1")
    echo "Choosing $baseName as a base name for translation files"
fi

for dir in "$1"/*; do
  echo "Processing $dir"
  locale=`basename "$dir"`
  targetLocale=$(echo $locale | cut -f1 -d-)

  if test -f "$dir/$baseName.xliff"; then
    fileName="$baseName.xliff"
    echo "Processing $locale xliff"

    if [ "$locale" != "$targetLocale" ];
    then
      echo "Changing locale from '$locale' to '$targetLocale'"
      sed -i '.bak' "s/target-language=\"$locale\"/target-language=\"$targetLocale\"/" "$dir/$fileName"
      rm "$dir/$fileName.bak"
    fi

    echo "Importing $dir/$fileName ..."
    xcodebuild -importLocalizations -project DuckDuckGo.xcodeproj -localizationPath "$dir/$fileName"

    if [ $? -ne 0 ]; then
       echo "ERROR: Failed to import $dir/$fileName"
       echo
       echo "Check translation folder and files then try again."
       echo
       exit 1
    fi

    echo "Reverting changes to stringsdict file"
    git checkout "DuckDuckGo/$targetLocale.lproj/Localizable.stringsdict"

  elif test -f "$dir/$baseName.stringsdict"; then
    fileName=$baseName.stringsdict
    echo "Processing $locale stringsdict"
    cp "$dir/$fileName" "DuckDuckGo/$targetLocale.lproj/Localizable.stringsdict"
  else
    echo "ERROR: $fileName xlif or stringsdict not found in $dir"
    echo
    exit 1
  fi

done
