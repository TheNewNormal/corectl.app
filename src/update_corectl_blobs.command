#!/bin/bash

#  update macOS clients
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh


# check and download latest version of corectl blobs
download_corectl_blobs
#

