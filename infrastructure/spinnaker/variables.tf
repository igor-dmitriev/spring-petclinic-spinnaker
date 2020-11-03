# Default
variable "aws_region" {}
variable "environment" {}

# EC2
variable "eip" {}
variable "eip_allocation_id" {}
variable "ec2_file_physical_path" {}
variable "ec2_instance_type" {}
variable "ec2_key_name" {}

# Network
variable "vpc" {}
variable "public_a_subnet" {}
variable "private_db_sg" {}
variable "public_app_sg" {}
variable "console_sg" {}
variable "default_sg" {}
variable "spinnaker_sg" {}

# Spinnaker
variable "spinnaker_version" {}
variable "spinnaker_db_password" {}
variable "spinnaker_auth_login" {}
variable "spinnaker_auth_password" {}

# Spinnaker Jenkins
variable "jenkins_password" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}