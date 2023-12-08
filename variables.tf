####################################
# AWS Authentication Configuration #
####################################

variable "aws_auth_accounts" {
  default     = []
  description = "List of AWS Account IDs to Associate w/ this Cluster (Adds All Users and Roles)"
  type        = list(string)
}

variable "aws_auth_roles" {
  default     = []
  description = "List of Custom AWS IAM Role Mappings for Kubernetes Users"

  type = list(object({
    groups   = list(string)
    rolearn  = string
    username = string
  }))
}

variable "aws_auth_role_nodes" {
  default     = []
  description = "ARNs of the IAM Role(s) Assigned to Kubernetes Nodes Hosted by AWS"
  type        = list(string)
}

variable "aws_auth_role_owners" {
  description = "ARNs of the AWS IAM Role(s) to Receive Unlimited System Access"
  type        = list(string)
}

variable "aws_auth_users" {
  default     = []
  description = "List of Custom AWS IAM User Mappings for Kubernetes Users"

  type = list(object({
    groups   = list(string)
    userarn  = string
    username = string
  }))
}

###########################################################################
# AWS Elastic Kubernetes Service (EKS) [Kubernetes] Cluster Configuration #
###########################################################################

variable "kubernetes_cluster_cidr" {
  description = "IPv4 CIDR Block Assignable to Resources Deployed to the Created EKS Cluster"
  type        = string
}

variable "kubernetes_cluster_enabled_logs" {
  description = "List of Kubernetes Cluster Logs to Enable and Send to CloudWatch"
  type        = list(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
}

variable "kubernetes_cluster_firewall_ids" {
  default     = null
  description = "List of AWS VPC [Network] Security Group [Firewall] IDs to Associate w/ Cluster"
  type        = list(string)
}

variable "kubernetes_cluster_log_retention" {
  default     = 7
  description = "Length of Time (in Days) to Retain Kubernetes Cluster Logs"
  type        = number
}

variable "kubernetes_cluster_name" {
  description = "Name to Assign to the Created EKS Cluster"
  type        = string
}

variable "kubernetes_cluster_network_id" {
  default     = null
  description = "ID of the Virtual Private Cloud (VPC) [Network] to Target"
  type        = string
}

variable "kubernetes_cluster_network_name" {
  default     = null
  description = "Name (Tag) of the Virtual Private Cloud (VPC) [Network] to Target"
  type        = string
}

variable "kubernetes_cluster_retain_logs" {
  default     = false
  description = "'true' if Logs Should be Retained if Cluster is Destroyed"
  type        = bool
}

variable "kubernetes_cluster_role_arn" {
  default     = null
  description = "ARN of the AWS IAM Role to Assign to the Created EKS Cluster"
  type        = string
}

variable "kubernetes_cluster_role_name" {
  default     = null
  description = "Name of the AWS IAM Role to Assign to the Created EKS Cluster"
  type        = string
}

variable "kubernetes_cluster_subnet_ids" {
  default     = null
  description = "List of AWS VPC [Network] Subnet IDs to Associate w/ Cluster"
  type        = list(string)
}

variable "kubernetes_cluster_trusted_cidrs" {
  default     = []
  description = "List of IPv4 CIDRs Permitted to Access the EKS Control Plane via Public Interface"
  type        = list(string)
}

##############################
# Resource Tag Configuration #
##############################

variable "tags_environment" {
  description = "Value to Assign to All 'Environment' Resource Tags"
  type        = string
}
