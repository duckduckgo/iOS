#!/bin/bash

SCRIPT_URL="https://raw.githubusercontent.com/duckduckgo/BrowserServicesKit/main/scripts/pre-commit.sh"
curl -s "${SCRIPT_URL}" | bash -s -- "$@"