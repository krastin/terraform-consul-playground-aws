resource "aws_vpc" "krastin-consul-dc1-vpc" {
  cidr_block = var.dc1-cidr_block
  enable_dns_hostnames = true

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "krastin-consul-dc1-vpc"
  }
}

resource "aws_internet_gateway" "krastin-consul-dc1-gw1" {
  vpc_id = aws_vpc.krastin-consul-dc1-vpc.id

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "krastin-consul-dc1-gw1"
  }
}

resource "aws_route" "default_route-dc1" {
  route_table_id         = aws_vpc.krastin-consul-dc1-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.krastin-consul-dc1-gw1.id
}

resource "aws_security_group" "krastin-consul-dc1-sg-permit" {
  name = "krastin-consul-dc1-sg-permit"
  description = "allow all inbound and outbound traffic"

  vpc_id = aws_vpc.krastin-consul-dc1-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "krastin-consul-dc1-sg-permit"
  }
}

resource "aws_subnet" "krastin-consul-dc1-subnet1" {
  vpc_id            = aws_vpc.krastin-consul-dc1-vpc.id
  cidr_block        = var.dc1-cidr_block
  map_public_ip_on_launch = true

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "krastin-consul-dc1-subnet1"
  }
}

output "vpc_id" {
  value = aws_vpc.krastin-consul-dc1-vpc.id
  description = "ID of this VPC"
  sensitive = false
}
