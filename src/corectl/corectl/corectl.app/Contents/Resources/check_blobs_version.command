#!/bin/bash

MATCH=$(/usr/local/sbin/corectld version | grep "suggested")

if [[ "${MATCH}" == *"suggested"* ]]; then
    # there is an update
    echo "yes"
else
    # no update available
    echo "no"
fi
