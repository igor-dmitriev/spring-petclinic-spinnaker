resource "aws_db_instance" "petclinic_db" {
  identifier = "petclinic-${var.environment}"
  allocated_storage = 20
  engine = "postgres"
  engine_version = "10.6"
  storage_type = "gp2"
  instance_class = "db.t2.micro"
  publicly_accessible = true
  auto_minor_version_upgrade = false
  db_subnet_group_name = "private_db_az_subnets"
  skip_final_snapshot = true
  vpc_security_group_ids = var.vpc_security_groups
  name = "petclinic"
  username = "petclinic"
  password = var.db_password
  deletion_protection = false

  tags = {
    Name = "petclinic-db"
  }

  lifecycle {
    prevent_destroy = false
  }
}