#!/bin/bash
#

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

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

echo " "
pause 'Press [Enter] key to continue...'
