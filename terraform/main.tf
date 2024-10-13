provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "my-user-documents"
}

module "ec2" {
  source        = "./modules/ec2"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  key_name      = "my-key"
  subnet_id     = "subnet-0bb1c79de3EXAMPLE"
}

module "rds" {
  source       = "./modules/rds"
  db_name      = "mydb"
  db_username  = "admin"
  db_password  = "mypassword"
}


module "lambda" {
  source = "./modules/lambda"  # Reference to the lambda module directory

  # Pass any variables needed by the module
  s3_bucket_name = aws_s3_bucket.lambda_bucket.bucket
}
