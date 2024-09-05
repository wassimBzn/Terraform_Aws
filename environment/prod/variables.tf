# variables.tf

variable "region" {
  default = "eu-west-3"
}
variable "availability_zone_1" {
  default = "eu-west-3a"
}
variable "availability_zone_2" {
  default = "eu-west-3b"
}
variable "ami" {
  default = "ami-0cdfcb9783eb43c45" # Amazon Linux 2 AMI ID for us-east-1
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  default     = "MyKey"  # Replace with your key pair name
}