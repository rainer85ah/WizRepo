# Get EKS cluster info from TFE
data "tfe_outputs" "infra" {
  organization = "Valuein"
  workspace    = "wiz-infra-dev"
}

# Get EKS cluster info
data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = local.cluster_name
}

locals {
  cluster_name = data.tfe_outputs.infra.values.eks_cluster_name
  eks_cluster_endpoint = data.tfe_outputs.infra.values.eks_cluster_endpoint
  cluster_certificate_authority_data = data.tfe_outputs.infra.values.cluster_certificate_authority_data
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(local.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
  }
}

resource "kubernetes_deployment" "webapp_deployment" {
  metadata {
    name      = "webapp-deployment"
    labels    = { app = "webapp" }
  }
  spec {
    replicas = 2
    selector { match_labels = { app = "webapp" } }
    template {
      metadata { labels = { app = "webapp" } }
      spec {
        container {
          name  = "webapp"
          image = "nginx:latest"
          port { container_port = 80 }
        }
      }
    }
  }
}

# The Nginx service is now of type ClusterIP, only for internal traffic.
resource "kubernetes_service" "webapp_service" {
  metadata {
    name = "webapp-service"
  }

  spec {
    selector = { app = "webapp" }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "LoadBalancer"
  }
}
