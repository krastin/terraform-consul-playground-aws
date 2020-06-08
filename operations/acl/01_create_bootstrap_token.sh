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

# consul acl bootstrap
echo Creating the bootstrap Token.
token_bootstrap=$(consul acl bootstrap -format=json | jq --raw-output '.SecretID')

echo "export CONSUL_HTTP_TOKEN=$token_bootstrap" > ~/consul_http_token.var
