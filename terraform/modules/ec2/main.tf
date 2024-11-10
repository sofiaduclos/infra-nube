resource "tls_private_key" "key_gen" {  
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  filename = "${path.module}/api-instance.pem"
  content  = tls_private_key.key_gen.private_key_openssh
}

resource "aws_key_pair" "key" {  
  key_name   = "api-instance-key"
  public_key = tls_private_key.key_gen.public_key_openssh
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_sqs_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy" "sqs_ssm_policy" {
  name        = "sqs_ssm_policy"
  description = "Policy to allow access to SQS and SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.sqs_ssm_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_sqs_ssm_instance_profile"  # Give a unique name to the instance profile
  role = aws_iam_role.ec2_role.name      # Associate the IAM role with the instance profile
}

resource "aws_launch_template" "api_instance" {
  name_prefix   = "api-instance"
  image_id      = var.ami_id
  instance_type = var.instance_type  # Use a variable for instance type
  key_name      = aws_key_pair.key.key_name

  # Attach the IAM instance profile to the instance
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name  # Use the instance profile name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnet_id
    security_groups      = [var.security_group_id]
  }
}

