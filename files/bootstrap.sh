#!/usr/bin/env bash

set -x

mkdir -p /etc/puppet/modules
puppet module install puppetlabs/vcsrepo
