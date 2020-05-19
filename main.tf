variable "aws_profile" {
  default = ""
}
variable "aws_region" {
  default = "eu-central-1"
}

variable "owner" {
  default = "testuser@company.com"
}

variable "ssh_key" {
  default = "~/.ssh/id_rsa"
}

provider "aws" {
  profile    = var.aws_profile
  region     = var.aws_region
}

# Consul DC1 related variables
variable "dc1-cidr_block" {
  default = "10.1.0.0/16"
}

variable "dc1-consul_version" {
  default = "" # no version get newest OSS
}

variable "dc1-consul_server_ips" {
  default = [
    "10.1.0.101",
    "10.1.0.102",
    "10.1.0.103",
  ]
}

variable "dc1-consul_client_ips" {
  default = [
    "10.1.0.201",
    "10.1.0.202",
    "10.1.0.203",
  ]
}
