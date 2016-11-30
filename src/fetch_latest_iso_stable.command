#!/bin/bash

#  fetch latest iso
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# set channel
CHANNEL=stable

echo " "
echo "Fetching lastest CoreOS $CHANNEL channel ISO…"
echo " "
#
~/bin/corectl pull --channel="$CHANNEL" 2>&1 | tee ~/.coreos/tmp/check_channel
CHECK_CHANNEL=$(cat ~/.coreos/tmp/check_channel | grep "downloading" | awk '{print $2}')
#
if [[ "$CHECK_CHANNEL" == "downloading" ]]; then
    echo " "
    echo "You will need to reload your VMs to use the lastest version."
    rm -f ~/.coreos/tmp/check_channel
else
    echo "You already have the latest CoreOS ISO."
fi

echo " "
pause 'Please press [Enter] to continue.'

exit 0
