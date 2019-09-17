variable "ssh_key" {
  default = "~/.ssh/id_rsa"
}

variable "consul_servers" {
  default = 3
}

variable "consul_node_ips" {}

resource "aws_instance" "krastin-consul-vm-node" {
  count = 9
  ami = "${data.aws_ami.consul.id}"
  instance_type = "t2.micro"
  private_ip = "${var.consul_node_ips[count.index]}"

  vpc_security_group_ids = ["${aws_security_group.krastin-consul-vpc-sg-permit.id}"]
  subnet_id = "${aws_subnet.krastin-consul-vpc-subnet-10-100.id}"

  credit_specification {
    cpu_credits = "unlimited"
  }

  provisioner "remote-exec" {
    inline = [
      # install consul binary
      "sudo -H -u consul -s env PRODUCT='1.6.0' /home/consul/install_consul.sh",

      # set up the first #consul_servers amount of nodes as SERVER=true and as bootstrap-expect as the amount of server nodes
      "sudo -H -u consul -s env RETRYIPS='${jsonencode(slice(var.consul_node_ips, 0, var.consul_servers))}' SERVER='${count.index < var.consul_servers ? "true" : "false"}' BOOTSTRAP='${var.consul_servers}' /home/consul/configure_consul.sh",

      # start up consul
      "sudo systemctl start consul"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      host = "${self.public_ip}"
      private_key = "${file(var.ssh_key)}"
    }
  }

  key_name = "krastin-key1"

  tags = {
    Name = "krastin-consul-vm-node.${count.index}"
  }
}

data "aws_ami" "consul" {
    most_recent = true

    filter {
        name   = "name"
        values = ["krastin-xenial-consul-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["729476260648"]
}

output "consul_public_ips" {
  value = "${zipmap(aws_instance.krastin-consul-vm-node.*.tags.Name, aws_instance.krastin-consul-vm-node.*.public_ip)}"
  sensitive = false
  description = "Public IP Addresses of nodes"
}