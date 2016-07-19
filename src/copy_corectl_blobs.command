#!/bin/bash

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

res_folder=$1

# copy blobs
# get password for sudo
my_password=$(security find-generic-password -wa corectl-app)
# reset sudo
sudo -k > /dev/null 2>&1
#
printf '%s\n' "$my_password" | sudo -Sv > /dev/null 2>&1

# copy blobs
sudo mkdir -p /usr/local/sbin > /dev/null 2>&1
echo "Copying files ..."
sudo cp -f "${res_folder}"/* /usr/local/sbin/
