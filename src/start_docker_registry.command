#!/bin/bash
# docker registry for corectl app

res_folder=$1

# copy registry config
mkdir -p ~/.coreos/registry
cp -f "${res_folder}"/registry/config.yml ~/.coreos/registry

# kill registry just in case it was left running
kill $(ps aux | grep "[r]egistry serve config.yml" | awk {'print $2'}) >/dev/null 2>&1
sleep 1

# start registry
echo "Starting Docker Registry v2 on 192.168.64.1:5000…"
cd ~/.coreos/registry
nohup "${res_folder}"/registry/registry serve config.yml >/dev/null 2>&1 &
