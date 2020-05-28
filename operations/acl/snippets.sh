# put acl_allow.hcl to all servers
# todo

# restart all servers but leader
# todo

# restart leader
# todo

# find out if there is a leader, returns 0 if true
unhealthy_cluster=$(consul info | grep -c 'leader_addr = $')

# find out leader, returns 1 if true
leader_node=$(consul info | grep -c 'leader = true')

# consul acl bootstrap
token_bootstrap=$(consul acl bootstrap -format=json | jq --raw-output '.SecretID')

# create agent policies
CONSUL_HTTP_TOKEN='$token_bootstrap' consul acl policy create -name default-agent-policy -rules @default-agent-policy.hcl -format=json

# create agent token
CONSUL_HTTP_TOKEN='$token_bootstrap' token_agent=$(consul acl token create -description "default agent token" -policy-name default-agent-policy -format=json | jq --raw-output '.SecretID')

cat <<EOF > agent-token.json
{
  "acl": {
    "tokens": {
      "agent": "$token_agent"
    }
  }
}
EOF
