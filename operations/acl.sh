#!/usr/bin/env bash

# Debug
# set -x

# We expect to see the following varibles
# SSH_KEY - location of the ssh key used to log in to the instances
# HOSTS - a comma separated list of the instaces' public IP addresses

# Stage 1:
# put the acl related config and common files on all servers
for HOST in $(echo $HOSTS | sed "s/,/ /g")
do
    ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST 'mkdir -p ~/consul-acl-bootstrap'
    scp -r -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes acl ubuntu@$HOST:~/consul-acl-bootstrap
    scp -r -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes actions ubuntu@$HOST:~/consul-acl-bootstrap
    ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST 'sudo cp ~/consul-acl-bootstrap/acl/acl_allow.hcl /etc/consul.d/acl_allow.hcl'
done
echo Done: put the acl related config and common files on all servers

# Stage 2:
# restart all servers but leader
for HOST in $(echo $HOSTS | sed "s/,/ /g")
do
    is_leader=$(ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/actions/check_is_leader.sh')
    if [ $is_leader == "0" ]; then
      ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST 'sudo systemctl restart consul'
    fi
done
echo Done: restarted all nodes but leader

# Stage 2.5:
# restart only the leader
for HOST in $(echo $HOSTS | sed "s/,/ /g")
do
    is_leader=$(ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/actions/check_is_leader.sh')
    if [ $is_leader == "1" ]; then
      ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST 'sudo systemctl restart consul'
      break
    fi
done
echo Done: restarted leader $HOST

# Stage 2.9:
# wait until re-election happens after restarting leader, up to a minute
for i in $(seq 1 6)
do 
  sleep 10 # wait 10 seconds
  is_leader=$(ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/actions/check_is_leader.sh')
  if [ $is_leader != "255" ]; then
    break
  fi
done

# Stage 3:
# create bootstrap tokens on leader
for HOST in $(echo $HOSTS | sed "s/,/ /g")
do
    is_leader=$(ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/actions/check_is_leader.sh')
    if [ $is_leader == "1" ]; then
      ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/acl/01_create_bootstrap_token.sh'
      ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/acl/02_create_agent_policy.sh'
      token_agent=$(ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/acl/03_create_agent_token.sh')
      break
    fi
done
echo Done: created bootstrap tokens on leader $HOST

# Stage 4:
# set up agent tokens on nodes
for HOST in $(echo $HOSTS | sed "s/,/ /g")
do
  ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST << EOF
    cat <<END > ~/consul-acl-bootstrap/acl/agent-token.json
{
  "acl": {
    "tokens": {
      "agent": "$token_agent"
    }
  }
}
END
    sudo cp ~/consul-acl-bootstrap/acl/agent-token.json /etc/consul.d/agent-token.json
    sudo cp ~/consul-acl-bootstrap/acl/acl_deny.hcl /etc/consul.d/acl_deny.hcl
    sudo rm /etc/consul.d/acl_allow.hcl
    test -f ~/consul_http_token.var && source ~/consul_http_token.var
    consul acl set-agent-token agent "$token_agent"
    echo "export CONSUL_HTTP_TOKEN=$token_agent" >> ~/.bash_profile
EOF
done
echo Done: deployed agent token config files to nodes

# Stage 5:
# restart all servers but leader
for HOST in $(echo $HOSTS | sed "s/,/ /g")
do
    is_leader=$(ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/actions/check_is_leader.sh')
    if [ $is_leader == "0" ]; then
      ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST 'sudo systemctl restart consul'
    fi
done
echo Done: restarted all nodes but leader

# Stage 5.5:
# restart only the leader
for HOST in $(echo $HOSTS | sed "s/,/ /g")
do
    is_leader=$(ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST '~/consul-acl-bootstrap/actions/check_is_leader.sh')
    if [ $is_leader == "1" ]; then
      ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ubuntu@$HOST 'sudo systemctl restart consul'
      break
    fi
done
echo Done: restarted leader node $HOST

echo ACL: Boostrapped!