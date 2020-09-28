#!/bin/sh

# Add target sub-directories here when needed
declare -a targets=("DuckDuckGo" "Widgets")

for dir in "${targets[@]}"; do
  echo Processing $dir
  find $dir/ -name "*.swift" -print0 | xargs -0 xcrun extractLocStrings -o $dir/en.lproj
done
