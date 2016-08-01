#!/bin/bash

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

res_folder=$1

# copy blobs
mkdir ~/bin > /dev/null 2>&1
echo "Copying files ..."
cp -f "${res_folder}"/* ~/bin/
