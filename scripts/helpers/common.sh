#!/bin/bash

export common_sh=1

#
# Output passed arguments to stderr and exit.
#
die() {
	cat >&2 <<< "$*"
	exit 1
}