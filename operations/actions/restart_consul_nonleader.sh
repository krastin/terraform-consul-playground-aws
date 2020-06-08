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
if [ $leader_node == "1" ]; then
    echo This is the cluster leader, skipping restart
    exit 1
else
    # restart consul
    sudo systemctl restart consul
fi

