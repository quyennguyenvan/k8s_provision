
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.13.1"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  enable_irsa = true

  create_iam_role = true
  iam_role_name   = "${var.cluster_name}-ClusterRole"

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  vpc_id                               = var.vpc_id
  subnet_ids                           = var.private_subnet_ids
  control_plane_subnet_ids             = var.control_plane_subnet_ids
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_security_group_name = "${var.cluster_name}-eks-cluster-sg"

  eks_managed_node_group_defaults = {
    create_iam_role = true
    ami_type        = "AL2_x86_64"
    disk_size       = 100
    instance_types  = var.eks_managed_node_group_defaults_instance_types
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = var.max_size
      desired_size = 1

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }
  # aws-auth configmap
  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  aws_auth_users            = var.aws_auth_users
  aws_auth_accounts         = var.aws_auth_accounts


  tags = var.default_tags

}
