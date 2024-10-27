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
