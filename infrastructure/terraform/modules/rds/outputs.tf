output "db_url" {
  value = aws_db_instance.petclinic_db.endpoint
}