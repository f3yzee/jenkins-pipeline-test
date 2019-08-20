provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "dmz-subnet-a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.dmz-subnet-a-cidr}"
  availability_zone = "${var.availability-zone-a}"
}

resource "aws_subnet" "dmz-subnet-b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.dmz-subnet-b-cidr}"
  availability_zone = "${var.availability-zone-b}"
}

resource "aws_subnet" "web-subnet-a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.web-subnet-a-cidr}"
  availability_zone = "${var.availability-zone-a}"
}

resource "aws_subnet" "web-subnet-b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.web-subnnet-b-cidr}"
  availability_zone = "${var.availability-zone-b}"
}

resource "aws_subnet" "ielb-subnet-a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.ielb-subnet-a-cidr}"
  availability_zone = "${var.availability-zone-a}"
}

resource "aws_subnet" "ielb-subnet-b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.ielb-subnet-b-cidr}"
  availability_zone = "${var.availability-zone-b}"
}

resource "aws_subnet" "app-subnet-a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.app-subnet-a-cidr}"
  availability_zone = "${var.availability-zone-a}"
}

resource "aws_subnet" "app-subnet-b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.app-subnet-b-cidr}"
  availability_zone = "${var.availability-zone-b}"
}

resource "aws_subnet" "data-subnet-a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.data-subnet-a-cidr}"
  availability_zone = "${var.availability-zone-a}"
}

resource "aws_subnet" "data-subnet-b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.data-subnet-b-cidr}"
  availability_zone = "${var.availability-zone-b}"
}

resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table" "web-public-rt-1" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.dmz-subnet-a.id}" 
  route_table_id = "${aws_route_table.web-public-rt.id}"
}

resource "aws_route_table_association" "web-public-rt-1" {
  subnet_id = "${aws_subnet.dmz-subnet-b.id}"
  route_table_id = "${aws_route_table.web-public-rt-1.id}"
}

resource "aws_security_group" "publicelb" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks =["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks =["0.0.0.0/0"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_elb" "pelb" {
  subnets =  ["${aws_subnet.dmz-subnet-a.id}"]
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
  instances                   = ["${aws_instance.wb-a.id}","${aws_instance.wb-b.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.publicelb.id}"]
  tags = {
    Name = "public load balancer"
  }
}

resource "aws_security_group" "dmz" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_security_group" "web-a" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.dmz-subnet-a-cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.dmz-subnet-a-cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.dmz-subnet-a-cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${var.dmz-subnet-a-cidr}"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_security_group" "web-b" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.dmz-subnet-b-cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.dmz-subnet-b-cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.dmz-subnet-b-cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${var.dmz-subnet-b-cidr}"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_instance" "wb-a" {
  ami  = "${var.ami}"
  instance_type = "${var.instance-type}"
  subnet_id = "${aws_subnet.web-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.web-a.id}"]
  associate_public_ip_address = false
  source_dest_check = false
}

resource "aws_instance" "wb-b" {
  ami = "${var.ami}"
  instance_type = "${var.instance-type}"
  subnet_id = "${aws_subnet.web-subnet-b.id}"
  vpc_security_group_ids = ["${aws_security_group.web-b.id}"]
  associate_public_ip_address = false
  source_dest_check = false
}

resource "aws_security_group" "elb" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.web-subnet-a-cidr}","${var.web-subnnet-b-cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks =["${var.web-subnet-a-cidr}","${var.web-subnnet-b-cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks =["${var.web-subnet-a-cidr}","${var.web-subnnet-b-cidr}"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_elb" "elb" {
  subnets =  ["${aws_subnet.ielb-subnet-a.id}"]
  internal =  true
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
  instances                   = ["${aws_instance.app-a.id}","${aws_instance.app-b.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.elb.id}"]
}

resource "aws_security_group" "app-a" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.ielb-subnet-a-cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.ielb-subnet-a-cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.ielb-subnet-a-cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${var.dmz-subnet-a-cidr}"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_security_group" "app-b" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.ielb-subnet-b-cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.ielb-subnet-b-cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.ielb-subnet-b-cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${var.dmz-subnet-b-cidr}"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_instance" "app-a" {
  ami  = "${var.ami}"
  instance_type = "${var.instance-type}"
  subnet_id = "${aws_subnet.app-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.app-a.id}"]
  associate_public_ip_address = false
  source_dest_check = false
}

resource "aws_instance" "app-b" {
  ami  = "${var.ami}"
  instance_type = "${var.instance-type}"
  subnet_id = "${aws_subnet.app-subnet-b.id}"
  vpc_security_group_ids = ["${aws_security_group.app-b.id}"]
  associate_public_ip_address = false
  source_dest_check = false
}

resource "aws_security_group" "data-a" {
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.app-subnet-a-cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.app-subnet-a-cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${var.dmz-subnet-a-cidr}"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_security_group" "data-b" {
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.app-subnet-b-cidr}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.app-subnet-b-cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${var.dmz-subnet-b-cidr}"]
  }
  vpc_id="${aws_vpc.main.id}"
}

resource "aws_instance" "db-a" {
  ami = "${var.ami}"
  instance_type = "${var.instance-type}"
  subnet_id = "${aws_subnet.data-subnet-a.id}"
  vpc_security_group_ids = ["${aws_security_group.data-a.id}"]
  source_dest_check = false
}

resource "aws_instance" "db-b" {
  ami = "${var.ami}"
  instance_type = "${var.instance-type}"
  subnet_id = "${aws_subnet.data-subnet-b.id}"
  vpc_security_group_ids = ["${aws_security_group.data-b.id}"]
  source_dest_check = false
}
