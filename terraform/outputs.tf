output "OIDC" {
  description = "OIDC provider to give access to IAM policies and attached resources"
  value = aws_eks_cluster.otel-demo.identity[0].oidc[0].issuer
}