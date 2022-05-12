#!/usr/bin/env bash

unhealthy_cluster=$(consul info | grep -c 'leader_addr = $')
if [ $unhealthy_cluster == "1" ]; then
    echo 255
    exit 255
fi

# find out leader, returns 1 if true
leader_node=$(consul info | grep -c 'leader = true')
if [ $leader_node == "0" ]; then
    echo 255
    exit 255
fi

if [ -f "$FILE" ]; then
    echo Cannot find file containing consul token '~/consul_http_token.var'
    exit 1
fi

source ~/consul_http_token.var

# create agent token
token_agent=$(consul acl token create -description "default agent token" -policy-name default-agent-policy -format=json | jq --raw-output '.SecretID')

echo $token_agent