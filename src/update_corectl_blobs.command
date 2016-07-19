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

# get password for sudo
my_password=$(security find-generic-password -wa corectl-app)
# reset sudo
sudo -k > /dev/null 2>&1
printf '%s\n' "$my_password" | sudo -Sv > /dev/null 2>&1

# copy blobs
echo "Copying files ..."
sudo cp -f * /usr/local/sbin/

echo "Remove old version unneeded blobs ..."
sudo rm -f /usr/local/sbin/corectld.nameserver > /dev/null 2>&1
sudo rm -f /usr/local/sbin/corectld.store > /dev/null 2>&1

#
cd ~/
rm -fr ~/tmp/corectl > /dev/null 2>&1

#
echo "Download has finished !!!"
echo " "

# check if corectld is running
CHECK_SERVER_STATUS=$(/usr/local/sbin/corectld status 2>&1 | grep "Uptime:")

if [[ "$CHECK_SERVER_STATUS" == "" ]]; then
    # corectld is not running
    echo "Corectld is updated to latest version ..."
else
    # check for active VMs
    vms=$(/usr/local/sbin/corectld status | grep "Active VMs:" | awk '{print $3}')
    if [[ "$vms" -ne "0" ]]; then
    # active VMs
        echo "You need to restart 'corectld' server via menu, but Halt all your VMs first, as you have $vms running !!! "
    else
        # no vms
        echo "You need to restart 'corectld' server via menu !!! "
    fi
fi

echo " "
pause 'Press [Enter] key to continue...'

