#!/bin/bash

SCRIPT_URL="https://raw.githubusercontent.com/duckduckgo/BrowserServicesKit/daniel/swiftlint-hook/scripts/pre-commit.sh"
curl -s "${SCRIPT_URL}" | bash -s -- "$@"