#!/bin/sh

# Get the directory where the script is stored
script_dir=$(dirname "$(readlink -f "$0")")
base_dir="${script_dir}/.."

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$FONTS_ENCRYPTION_KEY" \
--output fonts.zip "${script_dir}/assets/fonts.zip.gpg" && \
unzip -o fonts.zip -d "${base_dir}"                     && \
rm fonts.zip