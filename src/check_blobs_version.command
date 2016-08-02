#!/bin/bash

MATCH=$(~/bin/corectld version | grep "suggested")

if [[ "${MATCH}" == *"suggested"* ]]; then
    # there is an update
    echo "yes"
else
    # no update available
    echo "no"
fi
