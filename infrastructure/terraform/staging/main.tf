provider "aws" {
  profile = "default"
  region = var.region
  version = "~> 2.64"
}

locals {
  environment = "staging"
}

module "elb" {
  source = "../modules/elb"
  environment = local.environment
  security_groups = [
    var.public_app_sg,
    var.default_sg,
    var.console_sg
  ]
  subnets = [
    var.public_a_subnet,
    var.public_b_subnet
  ]
}

module "rds" {
  source = "../modules/rds"
  environment = local.environment
  vpc_security_groups = [
    var.default_sg,
    var.private_db_sg
  ]
  db_password = var.db_password
}

module "ssm" {
  source = "../modules/ssm"
  environment = local.environment
  db_url = split(":", module.rds.db_url)[0]
  db_password = var.db_password
}

module "iam" {
  source = "../modules/iam"
  environment = local.environment
}