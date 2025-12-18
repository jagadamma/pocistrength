# Create IAM role for SSM access
resource "aws_iam_role" "bastion_ssm_role" {
  name = "${var.name_prefix}-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "bastion_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_ssm_role.name
}

# Create an instance profile
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.name_prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion_ssm_role.name
}