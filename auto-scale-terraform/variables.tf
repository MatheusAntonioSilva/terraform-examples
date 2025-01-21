variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "private_a_cidr" {
  default = "192.168.3.0/24"
}

variable "ami" {
  default = "ami-047a51fa27710816e"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_pair" {
  default = "matheus"
}