provider "aws" {
  region = "us-east-1"
}

# Create a Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
}
 
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  depends_on = [ 
    aws_route_table.route_table
  ]
}
# Start of Selection
resource "aws_route_table_association" "route_table_association" {
  count = 2  # Asumiendo que tienes exactamente dos subredes

  subnet_id      = [aws_subnet.main.id, aws_subnet.main2.id][count.index]
  route_table_id = aws_route_table.route_table.id

  depends_on = [ 
    aws_route_table.route_table
  ]
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


# Create a Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "MainSubnet"
  }
}

resource "aws_subnet" "main2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "MainSubnet2"
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
  is_pwa = false
}

# S3 Module for PWA
module "pwa" {
  source        = "./modules/s3"
  bucket_name   = "pwa-bucket-${random_string.random.result}"
  is_static_site = false
  is_pwa        = true 
  pwa_file_path_folder = "../pwa/dist/pwa/browser"
  index_document = "index.html"
  error_document = "index.html"
}



# Create a Security Group for the LB
module "securityGroup" {
  source = "./modules/securityGroup"
  vpc_id = aws_vpc.main.id
}


resource "aws_lb_target_group" "api_target_group" {
  name     = "api-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id  # Ensure you pass the VPC ID

  health_check {
    port     = 80
    protocol = "HTTP"
  }

  tags = {
    Name = "api-target-group"
  }
}



# Create the Elastic Load Balancer
module "lb" {
  source               = "./modules/lb"
  name                 = "basic-lb"
  security_groups      = [module.securityGroup.id]
  subnet               = [aws_subnet.main.id, aws_subnet.main2.id]
  target_group_arn     = aws_lb_target_group.api_target_group.arn
}




# Create the EC2 template
module "ec2" {
  source        = "./modules/ec2"
  ami_id       = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  security_group_id = module.securityGroup.id
  code_bucket_name = "user-info-${random_string.random.result}"

  depends_on = [module.user_info]  # Ensure user_info module is completed first
}

# Create the Auto Scaling Group
resource "aws_autoscaling_group" "api_asg" {
  availability_zones = ["us-east-1a"]  # Use both AZs for high availability
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  target_group_arns = [aws_lb_target_group.api_target_group.arn]  # Register ASG instances with the target group

  launch_template {
    id      = module.ec2.launch_template_id  # Reference the launch template from the EC2 module
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "api-instance"
    propagate_at_launch = true
  }

  depends_on = [module.user_info]  # Ensure user_info module is completed first
}

# Attach the ASG to the LB
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.api_asg.name
  lb_target_group_arn     = aws_lb_target_group.api_target_group.arn
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.main.id, aws_subnet.main2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

module "rds" {
  source = "./modules/rds"
  db_name = "infra"
  db_username = "jabr7"
  db_password = "123456789"
  subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  security_group_id = module.securityGroup.id
}


module "user_info" {
  source                 = "./modules/replicatedBucket"
  source_bucket_name     = "user-info-${random_string.random.result}"
  destination_bucket_name = "user-info-replica-${random_string.random.result}"
  source_region          = "us-east-1"
  destination_region     = "us-west-2"
  iam_role_name          = "replication-role"
}


module "lambda_function" {
  source = "./modules/lambda"
}

module "sqs" {
  source = "./modules/sqs"
}

module "notification_lambda_and_SNS" {
  source = "./modules/notification_lambda_and_SNS"
  notification_email = "joaquinbonifacino7@gmail.com"
  sqs_queue_arn = module.sqs.sqs_queue_arn
}

