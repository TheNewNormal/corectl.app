#!/bin/bash

# check corectld server
#
CHECK_SERVER_STATUS=$(~/bin/corectld status 2>&1 | grep "Uptime:")

if [[ "$CHECK_SERVER_STATUS" == "" ]]; then
    # corectld is not running
    echo "no"
else
    # corectld is running
    echo "yes"
fi
