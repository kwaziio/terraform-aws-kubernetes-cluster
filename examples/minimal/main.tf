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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }
}

##############################
# AWS Provider Configuration #
##############################

provider "aws" {
  // DO NOT HARDCODE CREDENTIALS (Use Environment Variables)
}

######################################################
# Retrieves Information About the Active AWS Session #
######################################################

data "aws_caller_identity" "current" {}

#######################################################
# Requests Temporary EKS Cluster Authentication Token #
#######################################################

data "aws_eks_cluster_auth" "admin" {
  name = module.terraform_aws_kubernetes_cluster.cluster_name
}

#####################################
# Kubernetes Provider Configuration #
#####################################

provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.terraform_aws_kubernetes_cluster.cluster_ca_certificate)
  host                   = module.terraform_aws_kubernetes_cluster.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.admin.token
}

#########################################################
# Example Terraform AWS Kubernetes Cluster Module Usage #
#########################################################

module "terraform_aws_kubernetes_cluster" {
  source = "../../"

  aws_auth_role_owners            = [data.aws_caller_identity.current.arn]
  kubernetes_cluster_cidr         = "10.15.0.0/16"
  kubernetes_cluster_name         = "example-minimal"
  kubernetes_cluster_network_name = "internal-development"
  kubernetes_cluster_role_name    = "kwazi-internal-service-eks-cluster"
  tags_environment                = "development"
}
