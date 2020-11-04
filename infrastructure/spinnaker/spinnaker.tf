terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
  profile = "default"
  version = "~> 2.54"
}

locals {
  spinnaker_server_home_directory = "/home/ubuntu"
  jenkins_server_home_directory = "/home/ec2-user"
}

// IAM
resource "aws_iam_instance_profile" "spd_spinnaker_managing_spinnaker_instance_profile" {
  name = "spd-spinnaker-managing-SpinnakerInstanceProfile"
  role = aws_iam_role.spinnaker_auth_role.name
  path = "/"
}

resource "aws_iam_role" "spinnaker_managed" {
  name = "spinnakerManaged"
  path = "/"
  max_session_duration = "3600"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::933943444071:role/SpinnakerAuthRole"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role" "spinnaker_auth_role" {
  name = "SpinnakerAuthRole"
  path = "/"
  max_session_duration = "3600"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role_policy" "spinnaker_auth_role_spinnaker_assume_role_policy" {
  name = "SpinnakerAssumeRolePolicy"
  role = aws_iam_role.spinnaker_auth_role.id
  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:iam::933943444071:role/spinnakerManaged"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role_policy" "spinnaker_managed_spinnaker_pass_role" {
  name = "SpinnakerPassRole"
  role = aws_iam_role.spinnaker_managed.name
  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "iam:PassRole",
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role_policy_attachment" "spinnaker_auth_role_power_user_access" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role = aws_iam_role.spinnaker_auth_role.name
}

resource "aws_iam_role_policy_attachment" "spinnaker_managed_power_user_access" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role = aws_iam_role.spinnaker_managed.name
}

// RDS
resource "aws_db_instance" "spinnaker_db" {
  identifier = "spinnaker"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "5.7"
  storage_type = "gp2"
  instance_class = "db.t2.micro"
  publicly_accessible = true
  auto_minor_version_upgrade = false
  db_subnet_group_name = "private_db_az_subnets"
  skip_final_snapshot = true
  vpc_security_group_ids = [
    var.private_db_sg,
    var.default_sg
  ]
  name = "spinnakerdb"
  username = "spinnaker"
  password = var.spinnaker_db_password
  deletion_protection = false

  tags = {
    Name = "spinnaker-db"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id = aws_instance.spinnaker_instance.id
  allocation_id = var.eip_allocation_id
}

// EC2
resource "aws_instance" "spinnaker_instance" {
  ami = "ami-0817d428a6fb68645"
  instance_type = var.ec2_instance_type
  key_name = var.ec2_key_name
  associate_public_ip_address = true
  subnet_id = var.public_a_subnet
  vpc_security_group_ids = [
    var.default_sg,
    var.console_sg,
    var.spinnaker_sg
  ]
  iam_instance_profile = aws_iam_instance_profile.spd_spinnaker_managing_spinnaker_instance_profile.name

  tags = {
    Name = "spinnaker"
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 16
    volume_type = "gp2"
    iops = 100
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_dns
    private_key = file(var.ec2_file_physical_path)
  }

  # Install Halyard
  provisioner "file" {
    source = "install_halyard.sh"
    destination = "${local.spinnaker_server_home_directory}/install_halyard.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.spinnaker_server_home_directory}/install_halyard.sh",
      "${local.spinnaker_server_home_directory}/install_halyard.sh"
    ]
  }

  # Copy Spinnaker config files
  provisioner "remote-exec" {
    inline = [
      "mkdir ${local.spinnaker_server_home_directory}/.hal/default"
    ]
  }

  provisioner "file" {
    source = ".hal/default/profiles"
    destination = "${local.spinnaker_server_home_directory}/.hal/default"
  }

  provisioner "file" {
    source = ".hal/default/service-settings"
    destination = "${local.spinnaker_server_home_directory}/.hal/default"
  }

  # Replace environment variables in config.yml, change config.yml to config
  provisioner "file" {
    content = templatefile(".hal/config.yml", {
      SPINNAKER_PUBLIC_IP = var.eip
      SPD_JENKINS_PUBLIC_IP = aws_instance.jenkins.public_ip
      SPD_JENKINS_USERNAME = "jenkins"
      SPD_JENKINS_PASSWORD = var.jenkins_password
    })
    destination = "${local.spinnaker_server_home_directory}/.hal/config"
  }

  # Install Spinnaker
  provisioner "file" {
    content = templatefile("install_spinnaker.sh", {
      spinnaker_version = var.spinnaker_version
      spinnaker_ip = var.eip
      spinnaker_db_host = aws_db_instance.spinnaker_db.address
      spinnaker_db_password = aws_db_instance.spinnaker_db.password
      spinnaker_auth_login = var.spinnaker_auth_login
      spinnaker_auth_password = var.spinnaker_auth_password
    })
    destination = "${local.spinnaker_server_home_directory}/install_spinnaker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.spinnaker_server_home_directory}/install_spinnaker.sh",
      "${local.spinnaker_server_home_directory}/install_spinnaker.sh"
    ]
  }
}

resource "aws_instance" "jenkins" {
  ami = "ami-0947d2ba12ee1ff75"
  instance_type = "t2.medium"
  key_name = "spinnaker"
  vpc_security_group_ids = [
    var.default_sg,
    var.public_app_sg,
    var.console_sg
  ]
  subnet_id = var.public_a_subnet

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 32
    volume_type = "gp2"
    iops = 100
  }

  tags = {
    Name = "spinnaker-jenkins"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = self.public_dns
    private_key = file(var.ec2_file_physical_path)
  }

  provisioner "file" {
    // https://github.com/jenkinsci/configuration-as-code-plugin/issues/1189#issuecomment-560565982
    content = templatefile("jenkins.yml", {
      AWS_ACCESS_KEY = var.aws_access_key
      AWS_SECRET_KEY = var.aws_secret_key,
      GITHUB_PRIVATE_KEY = var.github_private_key
    })
    destination = "${local.jenkins_server_home_directory}/jenkins.yaml"
  }

  provisioner "file" {
    source = "install_jenkins.sh"
    destination = "${local.jenkins_server_home_directory}/install_jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.jenkins_server_home_directory}/install_jenkins.sh",
      "${local.jenkins_server_home_directory}/install_jenkins.sh ${var.jenkins_password}"
    ]
  }

  provisioner "file" {
    source = "id_rsa.pub"
    destination = "${local.jenkins_server_home_directory}/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source = "id_rsa"
    destination = "${local.jenkins_server_home_directory}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 600 ${local.jenkins_server_home_directory}/.ssh/id_rsa.pub",
      "sudo chmod 600 ${local.jenkins_server_home_directory}/.ssh/id_rsa",
      "eval $(ssh-agent -s)",
      "ssh-add ${local.jenkins_server_home_directory}/.ssh/id_rsa"
    ]
  }
}

// S3
resource "aws_s3_bucket" "petclinic_yum_repository" {
  bucket = "petclinic-yum-repository"
  region = var.aws_region

  lifecycle_rule {
    id = "expiration"
    enabled = true
    prefix = "x86_64/"
    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.petclinic_yum_repository.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "VpcRestrictionPolicy",
    "Statement": [
        {
            "Sid": "Access-to-Trusted-Users-only",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::933943444071:root"
                ]
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.petclinic_yum_repository.bucket}/*"
        },
        {
            "Sid": "Deny-Access-Except-For-Trusted-Users",
            "Effect": "Deny",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::933943444071:root"
                ]
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.petclinic_yum_repository.bucket}/*"
        }
    ]
}
POLICY
}