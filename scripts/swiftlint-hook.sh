#!/bin/bash

# URL where the installation/uninstallation script is hosted
SCRIPT_URL="https://raw.githubusercontent.com/duckduckgo/BrowserServicesKit/daniel/swiftlint-hook/scripts/swiftlint-hook.sh"
LOCAL_SCRIPT="local-install-pre-commit-hook.sh"

# Check the argument for install or uninstall
if [ "$1" != "--install" ] && [ "$1" != "--uninstall" ]; then
  echo "Usage: $0 --install | --uninstall"
  exit 1
fi

# Download the script
if command -v curl >/dev/null; then
  curl -s -o "$LOCAL_SCRIPT" "$SCRIPT_URL"
elif command -v wget >/dev/null; then
  wget -O "$LOCAL_SCRIPT" "$SCRIPT_URL"
else
  echo "error: Neither curl nor wget are available on your system. Please install one of them to proceed."
  exit 1
fi

# Make the script executable
chmod +x "$LOCAL_SCRIPT"

# Execute the script with the given option
./"$LOCAL_SCRIPT" "$1"

# Optionally, remove the downloaded script
rm "$LOCAL_SCRIPT"

echo "Operation completed!"