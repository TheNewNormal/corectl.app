#!/bin/bash
# halt corectld

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

sleep 3

# stop docker registry
kill $(ps aux | grep "[r]egistry serve config.yml" | awk {'print $2'}) >/dev/null 2>&1

# get password for sudo
my_password=$(security find-generic-password -wa corectl-app)
# reset sudo
sudo -k > /dev/null 2>&1

printf '%s\n' "$my_password" | sudo -Sv > /dev/null 2>&1

# kill all corectld processes
sudo pkill -f corectld
sudo pkill -f corectld.runner

