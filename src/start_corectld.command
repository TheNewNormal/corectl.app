#!/bin/bash
# start corectld

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get password for sudo
my_password=$(security find-generic-password -wa coreosctl-app)
# reset sudo
sudo -k > /dev/null 2>&1

printf '%s\n' "$my_password" | sudo -Sv > /dev/null 2>&1

# start corectld
sudo nohup /usr/local/sbin/corectld start --user $(whoami)
