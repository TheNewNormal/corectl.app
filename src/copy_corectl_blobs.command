#!/bin/bash

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

res_folder=$1

# create folder if does not exist
mkdir ~/bin > /dev/null 2>&1

# copy blobs
echo "Copying files…"
cp -f "${res_folder}"/* ~/bin/
