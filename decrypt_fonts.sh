#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$FONTS_ENCRYPTION_KEY" \
--output fonts.zip fonts.zip.gpg && \
unzip -o fonts.zip               && \
rm fonts.zip