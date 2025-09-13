# Create a highly permissive IAM policy
resource "aws_iam_policy" "highly_privileged_policy" {
  name        = "HighlyPrivilegedEC2Policy"
  description = "An overly permissive IAM policy for the EC2 instance (for demonstration)."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Create an IAM role for the EC2 instance
resource "aws_iam_role" "privileged_ec2_role" {
  name               = "PrivilegedEC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the overly permissive policy to the role
resource "aws_iam_role_policy_attachment" "attach_privileged_policy" {
  role       = aws_iam_role.privileged_ec2_role.name
  policy_arn = aws_iam_policy.highly_privileged_policy.arn
}

# Create an instance profile to associate the role with the EC2 instance
resource "aws_iam_instance_profile" "privileged_instance_profile" {
  name = "PrivilegedEC2InstanceProfile"
  role = aws_iam_role.privileged_ec2_role.name
}