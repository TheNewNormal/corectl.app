#!/bin/bash
#

# check for saved sudo password
my_password=$(security find-generic-password -wa corectl-app)

if [[ "${my_password}" == *"could not be found"* ]]
then
    # there is no sudo password set
    echo "no"
else
    # sudo password is saved
    # let's check if sudo password is correct

    # reset sudo
    sudo -k
    # check sudo
    printf '%s\n' "$my_password" | sudo -Sv > /dev/null 2>&1

    CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
    if [ ${CAN_I_RUN_SUDO} -gt 0 ]
    then
        # sudo password is correct
        echo "yes"
    else
        # sudo password is not correct
        echo "no"
    fi
fi
