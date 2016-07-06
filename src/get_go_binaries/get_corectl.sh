#!/bin/bash

# download corectl and corectld binaries

# get remote version
CORECTL_VERSION=$(curl -Ss https://api.github.com/repos/TheNewNormal/corectl/releases | grep "tag_name" | awk '{print $2}' | sed -e 's/"\(.*\)"./\1/' | head -1)

# download latest version of corectl for macOS
echo "Downloading corectl $CORECTL_VERSION for macOS"
curl -L -o corectl.tar.gz https://github.com/TheNewNormal/corectl/releases/download/$CORECTL_VERSION/corectl-$CORECTL_VERSION-macOS-amd64.tar.gz
tar xzvf corectl.tar.gz > /dev/null 2>&1
rm -f corectl.tar.gz
chmod +x *

# copy blobs
echo "Move files to ../bin"
#
mv -f corectld.runner ../bin
mv -f corectld ../bin
mv -f corectl ../bin


