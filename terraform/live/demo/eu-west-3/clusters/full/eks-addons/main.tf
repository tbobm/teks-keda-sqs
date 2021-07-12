locals {
  default_domain_name   = yamldecode(file("../../../../../global_values.yaml"))["default_domain_name"]
  default_domain_suffix = "${local.custom_tags["Env"]}.${local.custom_tags["Project"]}.${local.default_domain_name}"
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.eks.cluster_id
}

module "eks-addons" {
  source = "particuleio/addons/kubernetes//modules/aws"

  cluster-name = data.terraform_remote_state.eks.outputs.eks.cluster_id

  tags = merge(
    local.custom_tags
  )

  eks = {
    "cluster_oidc_issuer_url" = data.terraform_remote_state.eks.outputs.eks.cluster_oidc_issuer_url
  }

  aws-ebs-csi-driver = {
    enabled = true
  }

  aws-for-fluent-bit = {
    enabled = true
  }

  aws-load-balancer-controller = {
    enabled = true
  }

  aws-node-termination-handler = {
    enabled = true
  }

  cluster-autoscaler = {
    enabled = true
  }

  ingress-nginx = {
    enabled       = true
    use_nlb_ip    = true
    allowed_cidrs = data.terraform_remote_state.vpc.outputs.vpc.private_subnets_cidr_blocks
  }

  keda = {
    enabled   = true
    create_ns = true
  }

  metrics-server = {
    enabled       = true
    allowed_cidrs = data.terraform_remote_state.vpc.outputs.vpc.private_subnets_cidr_blocks
  }

}

output "eks-addons" {
  value     = module.eks-addons
  sensitive = true
}
