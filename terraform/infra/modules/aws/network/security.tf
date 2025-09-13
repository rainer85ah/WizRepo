# Security group for the EC2 instance (public)
resource "aws_security_group" "ec2_instance_sg" {
  name = "${var.prefix_name}-instance-sg"
  description = "EC2 instance security group"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix_name}-instance-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from the internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix_name}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access from the internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access from the internet"
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
    description     = "Allow HTTP to EKS nodes"
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
    description     = "Allow HTTPS to EKS nodes"
  }

  tags = {
    Name = "${var.prefix_name}-alb-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Security group for the EKS nodes
resource "aws_security_group" "eks_node_sg" {
  name        = "${var.prefix_name}-eks-node-sg"
  description = "EKS node security group"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix_name}-eks-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Rule to allow HTTP ingress to EKS nodes from the ALB
resource "aws_security_group_rule" "eks_node_sg_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "Allow HTTP from ALB for health checks"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# Rule to allow HTTPS ingress to EKS nodes from the ALB
resource "aws_security_group_rule" "eks_node_sg_ingress_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Allow HTTPS from ALB for health checks"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# Rule to allow all egress traffic from the EKS nodes
resource "aws_security_group_rule" "eks_node_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.eks_node_sg.id
}