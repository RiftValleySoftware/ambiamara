#!/bin/sh
if command -v jazzy; then
    CWD="$(pwd)"
    MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
    cd "${MY_SCRIPT_PATH}"
    rm -drf docs
    jazzy   --github_url https://github.com/RiftValleySoftware/ambiamara\
            --readme ./README.md \
            --theme fullwidth \
            --author The\ Great\ Rift\ Valley\ Software\ Company\
            --author_url https://riftvalleysoftware.com\
            --min-acl private \
            --copyright [©2018-2022\ The\ Great\ Rift\ Valley\ Software\ Company]\(https://riftvalleysoftware.com\) \
            --build-tool-arguments -workspace,"AmbiaMara.xcworkspace",-scheme,"AmbiaMara"
    cp icon.png docs/icon.png
    cp img/*.* docs/img/
    cd "${CWD}"
else
    echo "\nERROR: Jazzy is Not Installed.\n\nTo install Jazzy, make sure that you have Ruby installed, then run:\n"
    echo "[sudo] gem install jazzy\n"
fi
