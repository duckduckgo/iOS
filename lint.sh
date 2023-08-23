#!/bin/bash

FIX=false

if [[ "$1" == "--fix" ]]; then
    FIX=true
fi

if [[ -n "$CI" ]] || [[ -n "$BITRISE_IO" ]]; then
    echo "Skipping SwiftLint run in CI"
    exit 0
fi

# Add brew into PATH
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval $(/opt/homebrew/bin/brew shellenv)
fi

if test -d "$HOME/.mint/bin/"; then
    PATH="$HOME/.mint/bin/:${PATH}"
fi

export PATH


SWIFTLINT_COMMAND="swiftlint lint"
if $FIX; then
    SWIFTLINT_COMMAND="swiftlint lint --fix"
fi

if which swiftlint >/dev/null; then
   if [ "$CONFIGURATION" = "Release" ]; then
       $SWIFTLINT_COMMAND --strict
       if [ $? -ne 0 ]; then
           echo "error: SwiftLint validation failed."
           exit 1
       fi
   else
       $SWIFTLINT_COMMAND
   fi
else
   echo "error: SwiftLint not installed. Install using \`brew install swiftlint\`"
   exit 1
fi
