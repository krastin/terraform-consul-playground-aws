#!/usr/bin/env bash

# use the agent token if set up already
test -f ~/consul_http_token.var && source ~/consul_http_token.var

unhealthy_cluster=$(consul info | grep -c 'leader_addr = $')
if [ $unhealthy_cluster == "1" ]; then
    # Cluster does not have a leader, aborting!
    echo 255
    exit 255
fi

# find out leader, returns 1 if true
leader_node=$(consul info | grep -c 'leader = true')
echo $leader_node
