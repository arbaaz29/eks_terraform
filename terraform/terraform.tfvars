vpc_cidr = "10.0.0.0/16"
tag_name = "Finals"
basename = "EKS"
db_master_username = "admin"
db_name = "ecomdb"
public_subnet_cidrs = {
  subnet-az1 = {
    az   = "us-east-1a"
    cidr = "10.0.1.0/24"
    idx  = 1
  }
  subnet-az2 = {
    az   = "us-east-1b"
    cidr = "10.0.6.0/24"
    idx  = 2
  }
}
private_subnet_cidrs = {
  subnet-az1 = {
    az   = "us-east-1a" //dynamic label to identify us-east-az1
    cidr = "10.0.60.0/24"
    idx  = 1
  }
  subnet-az2 = {
    az   = "us-east-1b" //dynamic label to identify us-east-az2
    cidr = "10.0.120.0/24"
    idx  = 2
  }
}
private_subnet_cidrs_rds = {
  subnet-az1 = {
    az   = "us-east-1a" //dynamic label to identify us-east-az1
    cidr = "10.0.180.0/24"
    idx  = 1
  }
  subnet-az2 = {
    az   = "us-east-1b" //dynamic label to identify us-east-az2
    cidr = "10.0.240.0/24"
    idx  = 2
  }
}
instance_type_value = "t2.xlarge"
eks_version = "1.32"
eks_cluster = "otel-demo"
