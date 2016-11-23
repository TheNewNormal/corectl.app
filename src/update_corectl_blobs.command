#!/bin/bash

#  update macOS clients
#

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get remote version
CORECTL_VERSION=$(curl -Ss https://api.github.com/repos/TheNewNormal/corectl/releases | grep "tag_name" | awk '{print $2}' | sed -e 's/"\(.*\)"./\1/' | head -1)
#
mkdir -p ~/tmp/corectl > /dev/null 2>&1
cd ~/tmp/corectl

# download latest version of corectl for macOS
echo "Downloading corectl $CORECTL_VERSION for macOS"
curl -L -o corectl.tar.gz https://github.com/TheNewNormal/corectl/releases/download/$CORECTL_VERSION/corectl-$CORECTL_VERSION-macOS-amd64.tar.gz
tar xzvf corectl.tar.gz > /dev/null 2>&1
rm -f corectl.tar.gz
chmod +x *

# copy blobs
echo "Copying files to ~/bin …"
cp -f * ~/bin/ > /dev/null 2>&1

#
cd ~/
rm -fr ~/tmp/corectl > /dev/null 2>&1

#
echo "The download has finished."
echo " "

# check if corectld is running
CHECK_SERVER_STATUS=$(~/bin/corectld status 2>&1 | grep "Uptime:")

if [[ "$CHECK_SERVER_STATUS" == "" ]]; then
    # corectld is not running
    echo "Corectld is updated to latest version."
else
    # check for active VMs
    vms=$(~/bin/corectld status | grep "Active VMs:" | awk '{print $3}')
    if [[ "$vms" -ne "0" ]]; then
    # active VMs
        echo "You have $vms VMs running. Please stop them."
        echo "Then restart the 'corectld' server via the menu."
    else
        # no vms
        echo "Please restart the 'corectld' server via the menu."
    fi
fi

echo " "
pause 'Please press [Enter] to continue.'

exit 0


