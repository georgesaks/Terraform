variable "aws-region" {
  default = "us-east-1"
  type    = string
}

variable "vpc_id" {
  default = "vpc-029e37fe34cddbf7f"
  type    = string
}

variable "ami" {
  default = "ami-04a81a99f5ec58529"
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "key_name" {
  default = "Server_Jenkins_SG"
  type    = string
}

variable "cidr_blocks" {
  default = "73.76.77.44/32"
  type    = string
}