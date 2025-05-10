// this approach of pod identity has not been incroporated fully so there are less documentations on its application
//for now use the OIDC+IRSA approach which is widely adopted

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

//otel-demo
# resource "aws_iam_role" "otel-demo" {
#   name               = "eks-pod-identity-otel"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "otel-demo" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
#   role       = aws_iam_role.otel-demo.name
# }

# resource "aws_eks_pod_identity_association" "otel-demo" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "otel-demo"
#   service_account = "otel-collector"
#   role_arn        = aws_iam_role.otel-demo.arn
# }

//cloudwatch
resource "aws_iam_role" "cw" {
  name               = "eks-pod-identity-cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "cw" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cw.name
}

# resource "aws_eks_pod_identity_association" "cw" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "otel-demo"
#   service_account = "cloudwatch-agent"
#   role_arn        = aws_iam_role.cw.arn
# }

//alb

resource "aws_iam_role" "alb" {
  name               = "eks-pod-identity-alb"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "alb" {
  name = "alb-ingress"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTrustStores"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "StringEquals": {
                    "elasticloadbalancing:CreateAction": [
                        "CreateTargetGroup",
                        "CreateLoadBalancer"
                    ]
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "alb" {
  policy_arn = aws_iam_policy.alb.arn
  role       = aws_iam_role.alb.name
}

resource "aws_eks_pod_identity_association" "alb" {
  cluster_name    = aws_eks_cluster.otel-demo.name
  namespace       = "default"
  service_account = "alb-ingress-controller"
  role_arn        = aws_iam_role.alb.arn
}

//ebs-driver:
resource "aws_iam_role" "ebs-csi" {
  name               = "eks-pod-identity-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ebs-csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs-csi.name
}

# resource "aws_eks_pod_identity_association" "ebs-csi" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "default"
#   service_account = "ebs-csi-controller-sa"
#   role_arn        = aws_iam_role.ebs-csi.arn
# }

//grafana
# resource "aws_iam_role" "grafana" {
#   name               = "eks-pod-identity-grafana"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "grafana" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
#   role       = aws_iam_role.grafana.name
# }

# resource "aws_eks_pod_identity_association" "grafana" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "otel-demo"
#   service_account = "grafana"
#   role_arn        = aws_iam_role.grafana.arn
# }

//prometheus-otel-demo
# resource "aws_iam_role" "prometheus" {
#   name               = "eks-pod-identity-prometheus"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "prometheus" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
#   role       = aws_iam_role.prometheus.name
# }

# resource "aws_eks_pod_identity_association" "prometheus" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "otel-demo"
#   service_account = "prometheus"
#   role_arn        = aws_iam_role.prometheus.arn
# }

# //prometheus-test
# resource "aws_iam_role" "prometheus-test" {
#   name               = "eks-pod-identity-prometheus-test"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "prometheus-test" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
#   role       = aws_iam_role.prometheus-test.name
# }

# resource "aws_eks_pod_identity_association" "prometheus-test" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "test"
#   service_account = "prometheus"
#   role_arn        = aws_iam_role.prometheus-test.arn
# }

//vpc-cni
resource "aws_iam_role" "vpc-cni" {
  name               = "eks-pod-identity-vpc-cni"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "vpc-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc-cni.name
}

# resource "aws_eks_pod_identity_association" "vpc-cni" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "kube-system"
#   service_account = "aws-node"
#   role_arn        = aws_iam_role.vpc-cni.arn
# }

//monitoring-prom
# resource "aws_iam_role" "monitoring-prom" {
#   name               = "eks-pod-identity-monitoring-prom"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "monitoring-prom" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
#   role       = aws_iam_role.monitoring-prom.name
# }

# resource "aws_eks_pod_identity_association" "monitoring-prom" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "monitoring"
#   service_account = "prometheus-server"
#   role_arn        = aws_iam_role.monitoring-prom.arn
# }

# //monitoring-alertmanager
# resource "aws_iam_role" "monitoring-alertmanager" {
#   name               = "eks-pod-identity-monitoring-alertmanager"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "monitoring-alertmanager" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
#   role       = aws_iam_role.monitoring-alertmanager.name
# }

# resource "aws_eks_pod_identity_association" "monitoring-alertmanager" {
#   cluster_name    = aws_eks_cluster.otel-demo.name
#   namespace       = "monitoring"
#   service_account = "prometheus-alertmanager"
#   role_arn        = aws_iam_role.monitoring-alertmanager.arn
# }
