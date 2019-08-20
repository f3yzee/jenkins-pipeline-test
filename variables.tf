variable "aws_region" {
  description = "Region for the VPC"
  default = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "dmz-subnet-a-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.10.0/24"
}

variable "dmz-subnet-b-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.60.0/24"
}

variable "web-subnet-a-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.20.0/24"
}

variable "web-subnnet-b-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.70.0/24"
}

variable "ielb-subnet-a-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.30.0/24"
}

variable "ielb-subnet-b-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.80.0/24"
}

variable "app-subnet-a-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.40.0/24"
}

variable "app-subnet-b-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.90.0/24"
}

variable "data-subnet-a-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.50.0/24"
}

variable "data-subnet-b-cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.100.0/24"
}

variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-0bbc25e23a7640b9b"
}

variable "instance-type" {
    description = "instance type launched"
    default = "t2.micro"
}

variable "availability-zone-a" {
  default = "eu-west-1a"
}

variable "availability-zone-b" {
  default = "eu-west-1b"
}
