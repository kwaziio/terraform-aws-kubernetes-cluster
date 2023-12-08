# Minimal Usage Example

This example is intended to show a standard use case for this module with the least amount of recommended customization.

```HCL
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
```

## Executing Example Deployment

The following example is provided as guidance, but can also be used for integration testing:

* [https://github.com/kwaziio/terraform-aws-kubernetes-cluster/tree/main/examples/minimal](https://github.com/kwaziio/terraform-aws-kubernetes-cluster/tree/main/examples/minimal)

### Deploying Complex Example as Integration Test

The following commands will initialize and deploy the infrastructure for the minimal example:

```SHELL
terraform -chdir=examples/minimal init -reconfigure
terraform -chdir=examples/minimal apply
```

### Destroying Minimal Example After Integration Test

The following command will destroy any resources created while deploying the minimal example:

```SHELL
terraform -chdir=examples/minimal destroy
```
