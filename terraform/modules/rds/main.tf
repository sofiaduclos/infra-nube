resource "aws_db_instance" "postgres" {
  allocated_storage    = 10
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = var.subnet_group_name
  vpc_security_group_ids = [var.security_group_id]
  skip_final_snapshot    = true
}
