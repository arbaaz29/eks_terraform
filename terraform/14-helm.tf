# resource "null_resource" "update_helm_alb" {
#   provisioner "local-exec" {
#     command = "helm repo add prometheus-community https://aws.github.io/eks-charts"
#   }

#   depends_on = [aws_eks_cluster.otel-demo]
# }

# resource "null_resource" "update_helm_prom" {
#   provisioner "local-exec" {
#     command = "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts"
#   }

#   depends_on = [aws_eks_cluster.otel-demo]
# }

resource "null_resource" "update_helm" {
  provisioner "local-exec" {
    command = "helm repo update"
  }

  # depends_on = [null_resource.update_helm_alb, null_resource.update_helm_prom]
}

resource "helm_release" "alb" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "default"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.otel-demo.id
  }

  set {
    name  = "serviceAccount.name"
    value = "alb-ingress-controller"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  depends_on = [
    aws_eks_node_group.node_group,
    aws_iam_role_policy_attachment.alb
  ]
}

# resource "helm_release" "prometheus" {
#   name = "prometheus"

#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus"
#   namespace  = "otel-demo"

#   set {
#     name  = "alertmanager.enabled"
#     value = "false"
#   }

#   set {
#     name  = "kube-state-metrics.enabled"
#     value = "false"
#   }

#   set {
#     name  = "prometheus-node-exporter.enabled"
#     value = "false"
#   }

#   set {
#     name  = "prometheus-pushgateway.enabled"
#     value = "false"
#   }

#   set {
#     name  = "serviceAccount.server.name"
#     value = "prometheus"
#   }

#   # set {
#   #   name  = "serviceAccount.server.create"
#   #   value = "false"
#   # }

#   values = [ 
#     file("./values.yaml")
#    ]

#   depends_on = [
#     aws_eks_node_group.node_group,
#   ]
# }

# resource "helm_release" "cw" {
#   create_namespace = true
#   name = "cloudwatch"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-cloudwatch-metrics"
#   namespace  = "amazon-cloudwatch"
#   version    = "0.0.11"

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.otel-demo.id
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "cloudwatch-agent"
#   }


#   depends_on = [
#     # kubernetes_cluster_role.fluentd,
#     aws_eks_node_group.node_group,
#     aws_iam_role_policy_attachment.cw
#   ]
# }