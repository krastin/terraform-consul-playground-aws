resource "aws_instance" "krastin-consul-vm-node" {
  count = length(var.dc1-consul_server_ips)
  ami = data.aws_ami.consul.id
  instance_type = "m5.large"
  private_ip = var.dc1-consul_server_ips[count.index]

  vpc_security_group_ids = ["${aws_security_group.krastin-consul-dc1-sg-permit.id}"]
  subnet_id = aws_subnet.krastin-consul-dc1-subnet1.id

  credit_specification {
    cpu_credits = "unlimited"
  }

  provisioner "remote-exec" {
    inline = [
      # install consul binary
      "sudo -H -u consul -s env VERSION='${var.dc1-consul_version}' /home/consul/install_consul.sh",

      # set up the first #consul_servers amount of nodes as SERVER=true and as bootstrap-expect as the amount of server nodes
      "sudo -H -u consul -s env RETRYIPS='${jsonencode(slice(var.dc1-consul_server_ips, 0, length(var.dc1-consul_server_ips)))}' SERVER='${count.index < length(var.dc1-consul_server_ips) ? "true" : "false"}' BOOTSTRAP='${length(var.dc1-consul_server_ips)}' /home/consul/configure_consul.sh",

      # test auto-join
      "sudo rm /etc/consul.d/retry_join.json",
      #"echo -e 'retry_join = [\"provider=aws tag_key=CLUSTER tag_value=CONSUL\"]' | sudo tee /etc/consul.d/cloud_join.hcl",
      "echo 'retry_join = [\"provider=aws tag_key=CLUSTER tag_value=CONSUL access_key_id=${var.dc1-consul-autojoin-keyid} secret_access_key=${var.dc1-consul-autojoin-secretkey}\"]' | sudo tee /etc/consul.d/cloud_join.hcl",      

      # start up consul
      "sudo systemctl start consul"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      host = self.public_ip
      private_key = file(var.ssh_key)
    }
  }

  key_name = "krastin-key1"

  tags = {
    Owner = "krastin@hashicorp.com"
    # Keep  = ""
    Name = "krastin-consul-vm-node.${count.index}"
    CLUSTER = "CONSUL"
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
  value = zipmap(aws_instance.krastin-consul-vm-node.*.tags.Name, aws_instance.krastin-consul-vm-node.*.public_ip)
  sensitive = false
  description = "Public IP Addresses of nodes"
}
