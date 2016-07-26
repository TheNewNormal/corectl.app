#!/bin/bash

# shared functions library
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function pause(){
    read -p "$*"
}

function printLocalDns(){
    if nc -z localhost 53 1>/dev/null 2>&1
    then
        # port 53 is already bound, do not proceed:
        return
    fi
    local ALL_DNS='8.8.8.8:53,8.8.4.4:53'
    if [[ -r '/etc/resolv.conf' ]]
    then
        for dns in $( grep '^nameserver' '/etc/resolv.conf' | awk '{ print $2 }' )
        do
            ALL_DNS="$dns:53,$ALL_DNS"
        done
    fi
    echo "$ALL_DNS"
}
