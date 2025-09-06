resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  provider   = helm.eks

  values = [
    yamlencode({
      clusterName = var.eks_cluster_name
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }
    })
  ]
}

resource "kubernetes_deployment" "webapp" {
  provider = kubernetes.eks

  metadata {
    name      = "webapp"
    namespace = "default"
    labels = {
      app = "webapp"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "webapp"
      }
    }

    template {
      metadata {
        labels = {
          app = "webapp"
        }
      }

      spec {
        container {
          name  = "webapp"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "webapp_lb" {
  provider = kubernetes.eks
  depends_on = [helm_release.aws_lb_controller]
  
  metadata {
    name      = "webapp-lb"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"   = "alb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
    }
  }

  spec {
    selector = {
      app = "webapp"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "helm_release" "metrics_server" {
  provider   = helm.eks
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
}

# Horizontal Pod Autoscaler (HPA)
resource "kubernetes_horizontal_pod_autoscaler" "web" {
  provider = kubernetes.eks

  metadata {
    name = "web-hpa"
    namespace = "default"
  }

  spec {
    min_replicas = 1
    max_replicas = 2

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.webapp.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }
  }
}
