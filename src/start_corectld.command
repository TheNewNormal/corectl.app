#!/bin/bash
# start corectld

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# start corectld
~/bin/corectld start --user $(whoami)

