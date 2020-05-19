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

variable "instance_ssh_keyname" {}

provider "aws" {
  profile    = var.aws_profile
  region     = var.aws_region
}