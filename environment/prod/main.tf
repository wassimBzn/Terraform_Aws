# main.tf

provider "aws" {
  region = "eu-west-3" # Change this to your preferred region
}

# Create VPC
resource "aws_vpc" "axa_wassim_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "axa_wassim_vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "axa_wassim_igw" {
  vpc_id = aws_vpc.axa_wassim_vpc.id

  tags = {
    Name = "axa_wassim_igw"
  }
}

# Public Subnet 1
resource "aws_subnet" "axa_wassim_public_subnet_1" {
  vpc_id     = aws_vpc.axa_wassim_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "axa_wassim_public_subnet_1"
  }
}

# Public Subnet 2
resource "aws_subnet" "axa_wassim_public_subnet_2" {
  vpc_id     = aws_vpc.axa_wassim_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "axa_wassim_public_subnet_2"
  }
}

# Private Subnet
resource "aws_subnet" "axa_wassim_private_subnet" {
  vpc_id     = aws_vpc.axa_wassim_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.availability_zone_1

  tags = {
    Name = "axa_wassim_private_subnet"
  }
}

# Create a Route Table for the Public Subnet
resource "aws_route_table" "axa_wassim_public_rt" {
  vpc_id = aws_vpc.axa_wassim_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.axa_wassim_igw.id
  }

  tags = {
    Name = "axa_wassim_public_rt"
  }
}

# Associate Route Table with the Public Subnet 1
resource "aws_route_table_association" "axa_wassim_public_rta_1" {
  subnet_id      = aws_subnet.axa_wassim_public_subnet_1.id
  route_table_id = aws_route_table.axa_wassim_public_rt.id
}

# Associate Route Table with the Public Subnet 2
resource "aws_route_table_association" "axa_wassim_public_rta_2" {
  subnet_id      = aws_subnet.axa_wassim_public_subnet_2.id
  route_table_id = aws_route_table.axa_wassim_public_rt.id
}

# Security Group for Public Instances (Open to the Internet)
resource "aws_security_group" "axa_wassim_public_sg" {
  vpc_id = aws_vpc.axa_wassim_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "axa_wassim_public_sg"
  }
}

# Security Group for Private Instances (Open within VPC)
resource "aws_security_group" "axa_wassim_private_sg" {
  vpc_id = aws_vpc.axa_wassim_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.axa_wassim_public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "axa_wassim_private_sg"
  }
}

# Load Balancer
resource "aws_lb" "axa_wassim_lb" {
  name               = "axa-wassim-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.axa_wassim_public_sg.id]
  subnets            = [aws_subnet.axa_wassim_public_subnet_1.id, aws_subnet.axa_wassim_public_subnet_2.id]

  tags = {
    Name = "axa_wassim_lb"
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "axa_wassim_tg" {
  name     = "axa-wassim-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.axa_wassim_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "axa_wassim_lb_listener" {
  load_balancer_arn = aws_lb.axa_wassim_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.axa_wassim_tg.arn
  }
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "axa_wassim_lt" {
  name_prefix   = "axa-wassim-lt"
  image_id      = var.ami
  instance_type = var.instance_type

  key_name = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.axa_wassim_public_sg.id]
  }
  metadata_options {
    http_endpoint               = "enabled"  # Enables metadata service
    http_tokens                 = "optional" # Enforces IMDSv2 only
    http_put_response_hop_limit = 1
  }
  user_data = base64encode(file("userdata.sh"))

  tags = {
    Name = "axa_wassim_instance"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "axa_wassim_asg" {
  vpc_zone_identifier = [aws_subnet.axa_wassim_public_subnet_1.id, aws_subnet.axa_wassim_public_subnet_2.id]
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  launch_template {
    id      = aws_launch_template.axa_wassim_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.axa_wassim_tg.arn]

  tag {
    key                 = "Name"
    value               = "axa_wassim_asg_instance"
    propagate_at_launch = true
  }

}

# EC2 Instance in the Private Subnet
resource "aws_instance" "axa_wassim_private_ec2" {
  ami                    = var.ami # Amazon Linux 2 AMI in eu-west-3
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.axa_wassim_private_subnet.id
  vpc_security_group_ids = [aws_security_group.axa_wassim_private_sg.id]
  key_name               = var.key_name  # Replace with your key pair name

  user_data = file("userdata.sh")

  tags = {
    Name = "axa_wassim_private_instance"
  }
}