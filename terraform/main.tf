provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "MainInternetGateway"
  }
}

# Create a Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "MainRouteTable"
  }
}

# Create a Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "MainSubnet"
  }
}


resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false  # Ensure no uppercase letters
}

# S3 Module for Static Site
module "static_site" {
  source        = "./modules/s3"
  bucket_name   = "static-site-bucket-${random_string.random.result}"
  index_document = "index.html"
  error_document = "error.html"
  static_page_path = "../index.html"
  is_static_site = true
}

# S3 Module for PWA
module "pwa" {
  source        = "./modules/s3"
  bucket_name   = "pwa-bucket-${random_string.random.result}"
  index_document = "index.html"
  error_document = "error.html"
  static_page_path = "../index.html"
  is_static_site = true
}

output "static_site_url" {
  value = module.static_site.url
}



# Create the Auto Scaling Group
module "ec2" {
  source        = "./modules/ec2"
  ami_id       = "ami-06b21ccaeff8cd686"  # Replace with a valid AMI ID
  instance_type = "t3.micro"
  key_name      = "your-key-name"  # Replace with your key name
  subnet_id     = aws_subnet.main.id
}

# Create the ELB module
module "elb" {
  source              = "./modules/elb"  # Path to your ELB module
  name                = "my-load-balancer"
  subnets             = [aws_subnet.main.id]
  security_groups     = ["sg-12345678"]  # Replace with your security group IDs
  target_instance_arns = module.ec2.target_instance_arns  # Register the ASG instances
  vpc_id              = aws_vpc.main.id
}

# Output the Load Balancer URL
output "load_balancer_url" {
  value = module.elb.load_balancer_dns_name
}