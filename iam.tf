#Creat IAM Role for ECR
resource "aws_iam_role" "ecr_role" {
  name               = "ecr-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

#Create IAM policy to allow access to ECR
resource "aws_iam_policy" "ecr_policy" {
  name = "ecr-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Attach policy to the role
resource "aws_iam_policy_attachment" "attach" {
  name       = "ecr-attach"
  roles      = ["${aws_iam_role.ecr_role.name}"]
  policy_arn = aws_iam_policy.ecr_policy.arn
}

#Instance profile
resource "aws_iam_instance_profile" "iam_ec2_profile" {
  name = "iam-instance-profile"
  role = aws_iam_role.ecr_role.name
}
