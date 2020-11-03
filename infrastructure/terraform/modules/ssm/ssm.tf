resource "aws_ssm_parameter" "dbUrl" {
  name = "/petclinic/${var.environment}/db/url"
  description = "Petclinic AWS RDS MySQL url"
  type = "String"
  value = var.db_url
}

resource "aws_ssm_parameter" "dbPassword" {
  name = "/petclinic/${var.environment}/db/password"
  description = "Petclinic AWS RDS MySQL password"
  type = "SecureString"
  value = var.db_password
}