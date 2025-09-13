variable "prefix_name" {
  description = "Prefix Name"
  type        = string
  default     = "network"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "wiz-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of public subnet CIDRs (one per AZ)"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "A list of private subnet CIDRs (one per AZ)"
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "azs" {
  description = "A list of availability zones"
  type = list(string)
  default = []
}

variable "maximum_azs" {
  description = "Maximum number of availability zones"
  type        = number
  default     = 2
}