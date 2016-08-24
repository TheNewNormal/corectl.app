#!/bin/bash

# check if DNS port 53 is not in use
#
CHECK_DNS_STATUS=$(/usr/sbin/netstat -an | grep LISTEN | grep -w "127.0.0.1.53")

if [[ "$CHECK_DNS_STATUS" == "" ]]; then
    # DNS port is not in use
    echo "no"
else
    # DNS port is in use
    echo "yes"
fi
