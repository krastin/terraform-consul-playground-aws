#!/usr/bin/env bash

unhealthy_cluster=$(consul info | grep -c 'leader_addr = $')
if [ $unhealthy_cluster == "1" ]; then
    echo Cluster does not have a leader, aborting!
    exit 1
else
    echo Cluster seems healthy, moving on...
fi

# find out leader, returns 1 if true
leader_node=$(consul info | grep -c 'leader = true')
if [ $leader_node == "0" ]; then
    echo This is not the cluster leader, skipping.
    exit 1
fi

if [ -f "$FILE" ]; then
    echo Cannot find file containing consul token '~/consul_http_token.var'
    exit 1
fi

source ~/consul_http_token.var

# create agent policies
echo Creating the default agent policy
consul acl policy create -name default-agent-policy -rules @consul-acl-bootstrap/acl/default-agent-policy.hcl -format=json
