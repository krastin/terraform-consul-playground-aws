######################
## Consul variables  #
######################

variable "consul_version" {
  default = "" # if no version passed then get newest OSS
}

variable "consul_ami_filter" {
  default = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
}

variable "consul_server_ips" {
  default = [
    "10.1.0.101",
    "10.1.0.102",
    "10.1.0.103",
  ]
}

variable "consul_client_ips" {
  default = [
    "10.1.0.201",
    "10.1.0.202",
    "10.1.0.203",
  ]
}

variable "consul_license" {}
variable "consul-autojoin-keyid" {}
variable "consul-autojoin-secretkey" {}


######################
## AWS-VPC variables #
######################

variable "aws_profile" {
  default = ""
}
variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_prefix" {
  default = "test"
}

variable "datacenter" {
  default = "dc1"
}

variable "cidr_block" {
  default = "10.1.0.0/16"
}

variable "owner" {
  default = "testuser@company.com"
}

variable "ssh_key" {
  default = "~/.ssh/id_rsa"
}

variable "instance_ssh_keyname" {} 

provider "aws" {
  profile    = var.aws_profile
  region     = var.aws_region
}