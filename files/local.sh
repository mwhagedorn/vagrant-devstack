#!/usr/bin/env bash

TOP_DIR=$(cd $(dirname "$0") && pwd)
source $TOP_DIR/functions
source $TOP_DIR/stackrc
DEST=${DEST:-/opt/stack}

if is_service_enabled nova; then

    # PROJECT: demo
    source $TOP_DIR/openrc

    [[ ! -e $HOME/.ssh/id_rsa ]] && ssh-keygen -t rsa -N "" -f $HOME/.ssh/id_rsa

    for i in $HOME/.ssh/id_rsa.pub $HOME/.ssh/id_dsa.pub; do
        if [[ -r $i ]]; then
            nova keypair-add --pub_key=$i `hostname`
            break
        fi
    done

    # PRIVILEGED USER
    source $TOP_DIR/openrc admin admin

    nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

fi

if is_service_enabled neutron; then
    # PRIVILEGED USER
    source $TOP_DIR/openrc admin admin

    TENANT_ID=$(openstack project list | grep " demo " | get_field 1)

    NET_TESTING001=$(neutron net-create --tenant-id $TENANT_ID net-testing001 | grep ' id ' | get_field 2)
    NET_TESTING002=$(neutron net-create --tenant-id $TENANT_ID net-testing002 | grep ' id ' | get_field 2)

    SUBNET_TESTING001=$(neutron subnet-create --tenant-id $TENANT_ID --name subnet-testing001 $NET_TESTING001 10.10.0.0/24 | grep ' id ' | get_field 2)
    SUBNET_TESTING002=$(neutron subnet-create --tenant-id $TENANT_ID --name subnet-testing002 $NET_TESTING002 10.20.0.0/24 | grep ' id ' | get_field 2)

    ROUTER=$(neutron router-create --tenant-id $TENANT_ID router-testing | grep ' id ' | get_field 2)

    neutron router-interface-add $ROUTER $SUBNET_TESTING001
    neutron router-interface-add $ROUTER $SUBNET_TESTING002
fi
