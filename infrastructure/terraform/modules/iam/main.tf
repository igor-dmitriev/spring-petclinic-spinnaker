resource "aws_iam_instance_profile" "petclinic_ec2_instance_profile" {
  role = aws_iam_role.petclinic_ec2_role.name
}

resource "aws_iam_role" "petclinic_ec2_role" {
  name = "petclinic-ec2-${var.environment}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dcsSsm" {
  role       = aws_iam_role.petclinic_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}