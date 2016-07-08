#!/bin/bash

# shared functions library
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function pause(){
    read -p "$*"
}



