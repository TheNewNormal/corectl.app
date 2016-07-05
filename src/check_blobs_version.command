#!/bin/bash

# get installed version
INSTALLED_VERSION=v$(/usr/local/sbin/corectld version | grep "Version:" | head -1 | awk '{print $2}' | tr -d '\r')

# get remote version
CORECTL_VERSION=$(curl -Ss https://api.github.com/repos/TheNewNormal/corectl/releases | grep "tag_name" | awk '{print $2}' | sed -e 's/"\(.*\)"./\1/' | head -1)

MATCH=$(echo "${INSTALLED_VERSION}" | grep -c "${CORECTL_VERSION}")

if [ $MATCH -eq 0 ]; then
    # there is an update
    echo "yes"
else
    # no update available
    echo "no"
fi
