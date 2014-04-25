#!/bin/sh

# author: Christian Berendt <berendt@b1-systems.de>

if [[ $# -ne 1 ]]; then
    echo "usage: $0 VERSION"
    exit 1
fi

version=$1

vagrant destroy -f
vagrant up
vagrant package --output devstack-ubuntu-14.04-amd64-${version}.box
