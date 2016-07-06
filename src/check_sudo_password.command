#!/bin/bash
#

# check for saved sudo password
my_password=$(security 2>&1 > /dev/null find-generic-password -wa coreosctl-app)

if [[ "${my_password}" == *"could not be found"* ]]
then
    # there is no sudo password set
    echo "no"
else
    # sudo password is set
    echo "yes"
fi
