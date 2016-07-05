#!/bin/bash

# shared functions library
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function pause(){
    read -p "$*"
}

function save_password(){
# save user's password to Keychain
echo "  "
echo "Your Mac user's password will be saved in to 'Keychain' "
echo "and later one used for 'sudo' command to start 'corectld' server !!!"
echo " "
echo "Please type your Mac user's password followed by [ENTER]:"
read -s -r my_password
passwd_ok=0

# check if sudo password is correct
while [ ! $passwd_ok = 1 ]
do
    # reset sudo
    sudo -k
    # check sudo
    printf '%s\n' "$my_password" | sudo -Sv > /dev/null 2>&1
    CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
    if [ ${CAN_I_RUN_SUDO} -gt 0 ]
    then
        echo "The sudo password is fine !!!"
        echo " "
        passwd_ok=1
    else
        echo " "
        echo "The password you entered does not match your Mac user password !!!"
        echo "Please type your Mac user's password followed by [ENTER]:"
        read -s -r my_password
    fi
done

security add-generic-password -a coreosctl-app -s coreosctl-app -w $my_password -U

}


function download_corectl_blobs(){

# get installed version
INSTALLED_VERSION=v$(/usr/local/sbin/corectld version | grep "Version:" | head -1 | awk '{print $2}' | tr -d '\r')

# get remote version
CORECTL_VERSION=$(curl -Ss https://api.github.com/repos/TheNewNormal/corectl/releases | grep "tag_name" | awk '{print $2}' | sed -e 's/"\(.*\)"./\1/' | head -1)

MATCH=$(echo "${INSTALLED_VERSION}" | grep -c "${CORECTL_VERSION}")

if [ $MATCH -eq 0 ]; then
# the version is different
    mkdir -p ~/tmp/corectl > /dev/null 2>&1
    cd ~/tmp/corectl

    # download latest version of corectl for macOS
    echo "Downloading corectl $CORECTL_VERSION for macOS"
    curl -L -o corectl.tar.gz https://github.com/TheNewNormal/corectl/releases/download/$CORECTL_VERSION/corectl-$CORECTL_VERSION-osx-amd64.tar.gz
    tar xzvf corectl.tar.gz > /dev/null 2>&1
    rm -f corectl.tar.gz
    chmod +x *

    # get password for sudo
    my_password=$(security find-generic-password -wa coreosctl-app)
    # reset sudo
    sudo -k > /dev/null 2>&1
    printf '%s\n' "$my_password" | sudo -Sv > /dev/null 2>&1

    # copy blobs
    echo "Copying files ..."
    sudo cp -f * /usr/local/sbin

    #
    cd ~/
    rm -fr ~/tmp/corectl > /dev/null 2>&1

    #
    echo "Download has finished !!!"
    echo "You need to restart `corectld` server, but Halt all your VMs first !!! "
else
    echo " "
    echo "corectl is up to date ..."
    echo " "
fi

pause 'Press [Enter] key to continue...'

}



