#!/bin/bash
# halt corectld

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

sleep 3

# stop docker registry
kill $(ps aux | grep "[r]egistry serve config.yml" | awk {'print $2'}) >/dev/null 2>&1


