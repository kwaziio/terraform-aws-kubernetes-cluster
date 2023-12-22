# Terraform AWS Kubernetes Cluster Module by KWAZI

Terraform Module for Creating a Configurable Kubernetes Cluster on Amazon Web Services (AWS) with AWS Elastic Kubernetes Service (EKS)

## Getting Started

> NOTE: This section assumes that you have Terraform experience, have already created an AWS account, and have already configured programmatic access to that account via access token, Single-Sign On (SSO), or AWS Identity and Access Management (IAM) role. If you need help, [checkout our website](https://www.kwazi.io).

The simplest way to get started is to create a `main.tf` file with the minimum configuration options. You can use the following as a template:

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
  }
}

##############################
# AWS Provider Configuration #
##############################

provider "aws" {
  // DO NOT HARDCODE CREDENTIALS (Use Environment Variables)
}

#########################################################
# Example Terraform AWS Kubernetes Cluster Module Usage #
#########################################################

module "terraform_aws_kubernetes_cluster" {
  source = "../../"

  kubernetes_cluster_cidr         = "10.X.0.0/16"
  kubernetes_cluster_firewall_ids = "REPLACE_WITH_VPC_SG_IDS"
  kubernetes_cluster_name         = "REPLACE_WITH_CLUSTER_NAME"
  kubernetes_cluster_role_arn     = "REPLACE_WITH_CLUSTER_ROLE_ARN"
  kubernetes_cluster_subnet_ids   = REPLACE_WITH_VPC_SUBNET_IDS
}
```

In the example above, you should replace the following templated values:

Placeholder | Description
--- | ---
`REPLACE_WITH_CLUSTER_NAME` | Replace this w/ a Cluster Name that Makes Sense for Your Use Case
`REPLACE_WITH_CLUSTER_ROLE_ARN` | Replace this w/ the ARN of Your AWS IAM EKS Cluster Role
`REPLACE_WITH_VPC_SG_IDS` | Replace this w/ a List of VPC Security Group IDs
`REPLACE_WITH_VPC_SUBNET_IDS` | Replace this w/ a List of VPC Subnet IDs
`X` | Replace the Second Octet Value w/ Any Number from 0 to 255

## Prerequisites

We believe that authorization and firewall rules should be handled separately from common development processes. That's why we don't automate a few prerequisites required by this project, within this project. Those include:

1. Creating an AWS IAM Role for EKS
2. Creating an AWS VPC Security Group for EKS

### 1. Creating an AWS IAM Role for EKS

Amazon Web Services (AWS) provides a managed Identity and Access Management (IAM) policy designed specifically to support Elastic Kubernetes Service (EKS) clusters.

The easiest way to create the required AWS IAM role for EKS is to copy-and-paste the following snippet of code into the Terraform project where you manage your AWS IAM resources:

```HCL
############################################
# Creates an AWS IAM Role for EKS Clusters #
############################################

module "terraform_aws_role_eks_cluster" {
  source = "../../"

  iam_role_prefix = "IAM_ROLE_PREFIX"
}
```

In the example above, you should replace the following templated value:

Placeholder | Description
--- | ---
`IAM_ROLE_PREFIX` | Replace this w/ an Optional Prefix Used to Segregate Reusable Roles

#### Providing an ARN for Your AWS IAM Role for EKS Clusters

The AWS Identity and Access Management (IAM) Role for EKS Clusters can be assigned by providing its Amazon Resource Name (ARN) as an input for this module:

```HCL
#########################################################
# Example Terraform AWS Kubernetes Cluster Module Usage #
#########################################################

module "terraform_aws_kubernetes_cluster" {
  ...
  kubernetes_cluster_role_arn = ["arn:aws:iam::123456789:role/example-service-eks-cluster"]
  ...
}
```

### 2. Creating an AWS VPC Security Group for EKS

Amazon Web Services (AWS) assigns Virtual Private Cloud (VPC) security groups to Elastic Kubernetes Service (EKS) clusters. Before deploying this module, we recommend creating a VPC security group in your targeted VPC with the required rules.

The easiest way to create the required AWS VPC Security Group for EKS is to copy-and-paste the following snippet of code into the Terraform project where you manage your AWS networking resources:

```HCL
#################################################
# Creates a VPC Security Group for EKS Clusters #
#################################################

module "terraform_aws_firewall_eks_cluster" {
  source = "kwaziio/firewall-eks-cluster/aws"

  network_id = "NETWORK_ID"
}
```

In the example above, you should replace the following templated value:

Placeholder | Description
--- | ---
`NETWORK_ID` | Replace this w/ the ID of Your Targeted AWS Virtual Private Cloud (VPC)

#### Providing a List of VPC Security Group IDs

VPC Security Groups can be assigned by providing a list of IDs as an input for this module:

```HCL
#########################################################
# Example Terraform AWS Kubernetes Cluster Module Usage #
#########################################################

module "terraform_aws_kubernetes_cluster" {
  ...
  kubernetes_cluster_firewall_ids = ["sg-123456789"]
  ...
}
```

### Connecting to the Cluster

Kubernetes clusters hosted by Amazon Web Services (AWS) Elastic Kubernetes Service (EKS) rely on AWS Identity and Access Management (IAM) for authenticating requests to the cluster API.

The following command will update your local Kubernetes CLI (kubectl) configuration to use AWS IAM authentication when communicating with your cluster:

```BASH
aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
```

> NOTE: The example above assumes that you've already successfully authenticated with AWS via a locally-installed instance of the AWS CLI.

Variable Name | Variable Description
--- | ---
`AWS_REGION` | Name of the Cluster's AWS Region (Should Match `aws_region` Value)
`CLUSTER_NAME` | Name of the Targeted Cluster (Should Match `kubernetes_cluster_name` Value)

To verify that you've successfully authenticated, try executing the following command:

```BASH
kubectl get po -A
```

### Granting API Access

By default, Amazon Web Services (AWS) only permits the user that created an EKS cluster to communicate with the cluster API. This module dynamically modifies the cluster's configuration to grant access based on the following variable values:

Variable | Description
--- | ---
aws_auth_accounts | Adds All IAM Users and IAM Roles to the Cluster w/ No Access Rights
aws_auth_roles | Adds IAM Roles to the Cluster w/ Specified Access
aws_auth_role_nodes | Adds IAM Roles to the Cluster that Allow Nodes to Register
aws_auth_role_owners | Adds IAM Roles to the Cluster w/ Full System Access
aws_auth_users | Adds Individual IAM Users to the Cluster w/ Specified Access

The only required variable is `aws_auth_role_owners`, as this grants access to cluster owners, allowing them to administer the cluster.

## Need Help?

Working in a strict environment? Struggling to make design decisions you feel comfortable with? Want help from an expert that you can rely on -- one who won't abandon you when the job is finished?

Check us out at [https://www.kwazi.io](https://www.kwazi.io).

## Designing a Deployment

Before launching this module, your team should agree on the following decision points:

1. What CIDR should be used internally by the cluster?
2. What logging requirements are enforced by your organization?
3. Will your cluster need to be accessible by resources external to its VPC?

### What CIDR should be used internally by the cluster?

Amazon Web Services (AWS) offers an Elastic Kubernetes Service (EKS) add-on that allows for resources deployed to the cluster to leverage addresses in the hosting Virtual Private Cloud (VPC) instance.

While there is nothing inherently wrong with leveraging this feature, we frequently support multi-cloud environments and prefer when network addresses for Kubernetes resources are managed internally, simplifying address assignments when working with multiple Cloud Service Providers (CSP).

For this reason, we've omitted the configuration of the VPC Container Network Interface (CNI) add-on from this module. Instead, we require users to declare a unique CIDR that can be used by the cluster.

This CIDR should be unique within your organization. We typically recommend assigning a `10.X.0.0/16` CIDR that doesn't conflict with any of your existing networks. To assign a CIDR, set the following variable:

```HCL
kubernetes_cluster_cidr = "10.X.0.0/16" # Replace w/ Desired Network CIDR
```

### What logging requirements are enforced by your organization?

Organizations often have global policies regarding log retention for auditing purposes. By default, this module retains logs for 7 days and deletes all logs when the cluster is deleted.

If your organization has different requirements, you can apply them by setting the following variables:

```HCL
kubernetes_cluster_log_retention = 7     # Replace w/ Desired Retention Length (in Days)
kubernetes_cluster_retain_logs   = false # Replace w/ 'true' to Preserve Logs After Cluster Deletion
```

### Will your cluster's API need to be externally accessible?

There are two methods for interacting with an Amazon Web Services (AWS) Elastic Kubernetes Service (EKS) cluster's API: via a private interface or via a public interface.

If you're workstations and automation tools are positioned to interact with resources in the cluster's VPC via private IP address, then a public interface is unnecessary:

```HCL
kubernetes_cluster_trusted_cidrs = []
```

If you're workstations or automation tools (i.e., Terraform Cloud) are NOT able to communicate with resources in the cluster's VPC via private IP address, then a public interface is necessary.

You can provide a list of CIDRs permitted to contact the cluster's API by setting the following variable:

```HCL
kubernetes_cluster_trusted_cidrs = ["0.0.0.0/0"] # Replace w/ Stricter CIDR(s) if Desired
```

## Major Created Resources

The following table lists resources that this module may create in AWS, accompanied by conditions for when they will or will not be created:

Resource Name | Creation Condition
--- | ---
AWS CloudWatch Log Group | Always
AWS Elastic Kubernetes Service (EKS) Cluster | Always

## Usage Examples

The following example(s) are provided as guidance:

* [examples/complete](examples/complete/README.md)
