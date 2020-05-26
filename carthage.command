#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
carthage update --no-build --new-resolver
cd "${CWD}"
