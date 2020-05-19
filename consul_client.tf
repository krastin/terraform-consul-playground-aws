resource "aws_instance" "consul-client" {
  count = length(var.consul_client_ips)
  ami = data.aws_ami.ami-consul-client.id
  instance_type = "m5.large"
  private_ip = var.consul_client_ips[count.index]

  vpc_security_group_ids = ["${aws_security_group.secgrp-permit.id}"]
  subnet_id = aws_subnet.subnet-consul.id

  provisioner "remote-exec" {
    inline = [
      # install consul binary
      "sudo -H -u consul -s env VERSION='${var.consul_version}' /home/consul/install_consul.sh",

      # set up the first #consul_servers amount of nodes as SERVER=true and as bootstrap-expect as the amount of server nodes
      "sudo -H -u consul -s env RETRYIPS='${jsonencode(slice(var.consul_server_ips, 0, length(var.consul_server_ips)))}' SERVER=false BOOTSTRAP='0' /home/consul/configure_consul.sh",

      # test auto-join
      "sudo rm /etc/consul.d/retry_join.json",
      #"echo -e 'retry_join = [\"provider=aws tag_key=CLUSTER tag_value=CONSUL\"]' | sudo tee /etc/consul.d/cloud_join.hcl",
      "echo 'retry_join = [\"provider=aws tag_key=CLUSTER tag_value=CONSUL access_key_id=${var.consul-autojoin-keyid} secret_access_key=${var.consul-autojoin-secretkey}\"]' | sudo tee /etc/consul.d/cloud_join.hcl",      

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

  key_name = var.instance_ssh_keyname

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "${var.aws_prefix}-${var.datacenter}-consul-client.${count.index}"
    CLUSTER = "CONSUL"
    Datacenter = var.datacenter
  }
}

data "aws_ami" "ami-consul-client" {
    most_recent = true

    filter {
        name   = "name"
        values = ["${var.consul_ami_filter}"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["729476260648"]
}

output "consul_clients_public_ips" {
  value = zipmap(aws_instance.consul-client.*.tags.Name, aws_instance.consul-client.*.public_ip)
  sensitive = false
  description = "Public IP Addresses of Consul client nodes"
}
