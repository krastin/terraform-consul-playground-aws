resource "aws_vpc" "krastin-consul-vpc" {
  cidr_block = "10.100.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "krastin-consul-vpc"
  }
}

resource "aws_internet_gateway" "krastin-consul-gw1" {
  vpc_id = "${aws_vpc.krastin-consul-vpc.id}"

  tags = {
    Name = "krastin-consul-gw1"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = "${aws_vpc.krastin-consul-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.krastin-consul-gw1.id}"
}

resource "aws_security_group" "krastin-consul-vpc-sg-permit" {
  name = "krastin-consul-vpc-sg-permit"
  description = "allow all inbound and outbound traffic"

  vpc_id = "${aws_vpc.krastin-consul-vpc.id}"

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
    Name = "krastin-consul-vpc-sg-permit"
  }
}

resource "aws_subnet" "krastin-consul-vpc-subnet-10-100" {
  vpc_id            = "${aws_vpc.krastin-consul-vpc.id}"
  cidr_block        = "10.100.0.0/16"
  map_public_ip_on_launch = true
  # availability_zone = "us-east-1"

  tags = {
    Name = "krastin-consul-vpc-subnet-10-100"
  }
}

output "vpc_id" {
  value = "${aws_vpc.krastin-consul-vpc.id}"
  description = "ID of this VPC"
  sensitive = false
}
