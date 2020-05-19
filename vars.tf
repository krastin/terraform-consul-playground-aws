variable "datacenter" {
  default = "dc1"
}

variable "cidr_block" {
  default = "10.1.0.0/16"
}

variable "consul_version" {
  default = "" # no version get newest OSS
}

variable "consul_ami_version" {
  default = "1.7.3-ent" # no version get 1.7.3+ent NOTE: use dash instead of plus here
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

variable "consul-autojoin-keyid" {}
variable "consul-autojoin-secretkey" {}
