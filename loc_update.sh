#!/bin/sh

# Add target sub-directories here when needed
declare -a targets=("DuckDuckGo" "Widgets")

for dir in "${targets[@]}"; do
  echo Processing $dir
  find $dir/ -name "*.swift" -print0 | xargs -0 xcrun extractLocStrings -o $dir/en.lproj
  iconv -f UTF-16 -t UTF8 $dir/en.lproj/Localizable.strings > $dir/en.lproj/Localizable-UTF8.strings
  mv $dir/en.lproj/Localizable-UTF8.strings $dir/en.lproj/Localizable.strings
done
