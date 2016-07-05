#!/bin/bash
#

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# check for saved sudo password
my_password=$(security 2>&1 > /dev/null find-generic-password -wa coreosctl-app)

if [[ "${my_password}" == *"could not be found"* ]]
then
    save_password
fi
