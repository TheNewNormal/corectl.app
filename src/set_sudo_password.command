#!/bin/bash
#

# save user's password to Keychain
my_password=$1

security add-generic-password -a corectl-app -s corectl-app -w $my_password -U

