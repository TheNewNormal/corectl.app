#!/bin/bash

# compile corectl and corectld binaries

current_folder=$(pwd)

# clean up go folders 
rm -rf $GOPATH/src/github.com/TheNewNormal/corectl
#
mkdir -p $GOPATH/src/github.com/TheNewNormal

#
cd $GOPATH/src/github.com/TheNewNormal
#
git clone https://github.com/TheNewNormal/corectl
cd corectl
git checkout golang

#
opam init --yes
opam pin add qcow-format git://github.com/mirage/ocaml-qcow#master --yes
opam install --yes uri qcow-format ocamlfind
eval `opam config env`

# build
make hyperkit
make

#
cd $current_folder
cp -f $GOPATH/src/github.com/TheNewNormal/corectl/bin/corectld.runner ../bin
cp -f $GOPATH/src/github.com/TheNewNormal/corectl/bin/corectld ../bin
cp -f $GOPATH/src/github.com/TheNewNormal/corectl/bin/corectl ../bin
