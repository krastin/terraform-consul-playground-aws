# terraform-consul-playground-aws
A Consul testing playground for AWS

# Purpose

This repository attempts to store the minimum amount of code that is required to create the basic Consul [reference architecture](https://learn.hashicorp.com/consul/datacenter-deploy/reference-architecture#infrastructure-diagram)

- a single VPC for a datacenter
- 3 Consul Server nodes
- 3 Consul Client nodes

# Prerequisites
## Install packer
Grab terraform and learn how to install it from [here](https://www.terraform.io/downloads.html).

## Install aws-cli
Grab aws-cli and learn how to install it from [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html).
You will need a setup where the aws-cli tools can freely manage your infrastucture. Check the AWS help pages for more info.

## Create permissions for node auto-discovery
You will need an IAM role with _ec2:DescribeInstances_ permissions so that the Consul nodes can auto-discover themselves. If this does not mean anything to you, please check out [this guide](https://www.hashicorp.com/blog/consul-auto-join-with-cloud-metadata/).

## Configure the variables
### AWS variables

- aws_profile = the name of the profile used by aws-cli, e.g. "aws-work-dev"
- aws_region = the region to which you'd be deploting, e.g. "eu-central-1"
- aws_prefix = the prefix of all the resources created, e.g. "test1001"
- datacenter = a naming abstraction for the VPC, e.g. "dc1"
- cidr_block = the subnet for the VPC, e.g. "10.1.0.0/16"
- owner = name or email of the owner, set as a tag for each resource, e.g. "john@doe.com"
- ssh_key = the path to the ssh key used to connect to the instances and do provisioning, e.g. "/Users/admin/.ssh/aws-work-dev-euc1-key1.pem"
- instance_ssh_keyname = the name of the pre-created AWS keypair that the instances will be set up with, e.g. "instance-dev-key1"

### Consul Variables

- consul_version = consul version to be installed with the provisioner script, e.g. "1.7.3+ent"
- consul_ami_filter = filter to select which AMI to use for the Consul nodes - uses latest if more than one result, e.g. "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
- consul-autojoin-keyid = the auto-join related IAM role key id, e.g. "AXXXXXXXXXXXXXXXXXXX"
- consul-autojoin-secretkey = the auto-join related IAM role secret key, e.g. "veryverySECRETmuchHIDDENsuchDANGER"
- consul_server_ips = an array of IPs for the Consul servers, e.g. ["10.1.0.101","10.1.0.102","10.1.0.103",]
- consul_client_ips = an array of IPs for the Consul clients, e.g. ["10.1.0.201","10.1.0.202","10.1.0.203",]

# How to build the platform

    terraform init
    terraform apply

# How to test
ToDo

# To Do
- [ ] add testing
- [ ] add link to building your own Consul AMI

# Done
- [x] build initial version
