#!/bin/bash

# check corectld server
#

INSTALLED_VERSION=v$(/usr/local/sbin/corectld version | grep "Version:" | head -1 | awk '{print $2}' | tr -d '\r')
echo "${INSTALLED_VERSION}"

