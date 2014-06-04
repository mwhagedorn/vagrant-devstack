#!/bin/bash

set -x

for repository in $(ls -d1 /opt/stack/*); do
    pushd $repository
    tox --notest
    popd
done
