###########################
# Terraform Configuration #
###########################

terraform {
  required_version = ">= 1.6.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21"
    }
  }
}

##############################
# AWS Provider Configuration #
##############################

provider "aws" {
  // DO NOT HARDCODE CREDENTIALS (Use Environment Variables)
}

###################################
# Required Prerequisite Resources #
###################################

module "terraform_aws_role_eks_cluster" {
  source = "kwaziio/role-eks-cluster/aws"

  iam_role_prefix = "example-service-"

  resource_tags = {
    Environment = "examples"
  }
}

module "terraform_aws_role_eks_node" {
  source = "kwaziio/role-eks-node/aws"

  iam_role_enable_ebs_csi        = true
  iam_role_enable_efs_csi        = true
  iam_role_enable_full_s3_access = true
  iam_role_prefix                = "example-service-"

  resource_tags = {
    Environment = "examples"
  }
}

module "network" {
  source = "kwaziio/network/aws"

  network_primary_cidr_block = "10.0.0.0/16"
  network_tags_name          = "example-network"
  network_trusted_ipv4_cidrs = ["0.0.0.0/0"]

  subnets_private = [
    {
      cidr = "10.0.0.0/19",
      name = "private-a",
      zone = "a",
    },
    {
      cidr = "10.0.32.0/19",
      name = "private-b",
      zone = "b",
    },
    {
      cidr = "10.0.64.0/19",
      name = "private-c",
      zone = "c",
    },
  ]

  subnets_public = [
    {
      cidr = "10.0.192.0/20",
      name = "public-a",
      zone = "a",
    },
    {
      cidr = "10.0.208.0/20",
      name = "public-b",
      zone = "b",
    },
    {
      cidr = "10.0.224.0/20",
      name = "public-c",
      zone = "c",
    },
  ]
}

module "terraform_aws_firewall_eks_cluster" {
  source = "kwaziio/firewall-eks-cluster/aws"

  network_id = module.network.network_id
}

module "terraform_aws_firewall_eks_node" {
  source = "kwaziio/firewall-eks-node/aws"

  firewall_bastion_id = module.network.firewall_bastion_id
  network_id          = module.network.network_id
}

######################################################
# Retrieves Information About the Active AWS Session #
######################################################

data "aws_caller_identity" "current" {}

#########################################################
# Example Terraform AWS Kubernetes Cluster Module Usage #
#########################################################

module "terraform_aws_kubernetes_cluster" {
  source = "../../"

  kubernetes_cluster_cidr         = "10.15.0.0/16"
  kubernetes_cluster_firewall_ids = [module.terraform_aws_firewall_eks_cluster.id]
  kubernetes_cluster_name         = "example-cluster"
  kubernetes_cluster_role_arn     = module.terraform_aws_role_eks_cluster.id
  kubernetes_cluster_subnet_ids   = module.network.subnets_private.*.id
}
