#!/usr/bin/env bash

set -x

apt-get update
apt-get upgrade -y
apt-get install -y puppet
mkdir -p /etc/puppet/modules
puppet module install puppetlabs/vcsrepo
