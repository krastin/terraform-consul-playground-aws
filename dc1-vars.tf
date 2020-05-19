
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

variable "dc1-consul-autojoin-keyid" {}
variable "dc1-consul-autojoin-secretkey" {}
