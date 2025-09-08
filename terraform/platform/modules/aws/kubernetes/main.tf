# Single ClusterRoleBinding to bind 'eks-administrators' group to cluster-admin
resource "kubernetes_cluster_role_binding_v1" "eks_admins_binding" {
  metadata {
    name = "eks-admins-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "Group"
    name      = "eks-administrators"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "helm_release" "aws_lb_controller" {
  depends_on = [kubernetes_cluster_role_binding_v1.eks_admins_binding]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  replace    = true
  wait       = true
  atomic     = true
  timeout    = 900

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region = var.aws_region
      vpcId  = var.vpc_id
      installCRDs = true

      serviceAccount = {
        create = false
        name   = var.eks_admin_sa_role_name
        annotations = {
          "eks.amazonaws.com/role-arn" = var.eks_admin_sa_role_arn
        }
      }
      rbac = {
        create = true
      }
    })
  ]
}

resource "null_resource" "webapp_lb_cleanup" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command     = "kubectl delete service webapp-lb -n default || true"
    interpreter = ["/bin/sh", "-c"]
  }
}

resource "kubernetes_service" "webapp_lb" {
  depends_on = [
    null_resource.webapp_lb_cleanup,
    helm_release.aws_lb_controller,
    kubernetes_deployment.webapp
  ]

  metadata {
    name      = "webapp-lb"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"   = "alb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
      "service.beta.kubernetes.io/aws-load-balancer-target-type" = "ip"
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

resource "kubernetes_deployment" "webapp" {
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
