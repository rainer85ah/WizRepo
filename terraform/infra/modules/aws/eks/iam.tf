resource "aws_iam_role" "eks_admin_sa_role" {
  name = "${var.eks_cluster_name}-eks-admin-sa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_provider_arn, "/^[^/]*//", "")}:sub" = "system:serviceaccount:kube-system:eks-admin-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_role_attach" {
  role       = aws_iam_role.eks_admin_sa_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
