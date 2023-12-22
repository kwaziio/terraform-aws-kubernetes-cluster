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
  description = "List of AWS VPC [Network] Security Group [Firewall] IDs to Associate w/ Cluster"
  type        = list(string)
}

variable "kubernetes_cluster_log_kms_key" {
  default     = null
  description = "ID of the KMS Key to Utilize When Encrypting Kubernetes Cluster Logs"
  type        = string
}

variable "kubernetes_cluster_log_group_class" {
  default     = "STANDARD"
  description = "Storage Class to Utilize When Storing Kubernetes Cluster Logs"
  type        = string
}

variable "kubernetes_cluster_log_retention" {
  default     = 7
  description = "Length of Time (in Days) to Retain Kubernetes Cluster Logs"
  type        = number
}

variable "kubernetes_cluster_manage_log_group" {
  default     = true
  description = "'true' if Terraform Should Managed Kubernetes Cluster Logs"
  type        = bool
}

variable "kubernetes_cluster_name" {
  description = "Name to Assign to the Created EKS Cluster"
  type        = string
}

variable "kubernetes_cluster_retain_logs" {
  default     = false
  description = "'true' if Logs Should be Retained if Cluster is Destroyed"
  type        = bool
}

variable "kubernetes_cluster_role_arn" {
  description = "ARN of the AWS IAM Role to Assign to the Created EKS Cluster"
  type        = string
}

variable "kubernetes_cluster_subnet_ids" {
  description = "List of AWS VPC [Network] Subnet IDs to Associate w/ Cluster"
  type        = list(string)
}

variable "kubernetes_cluster_trusted_cidrs" {
  default     = []
  description = "List of IPv4 CIDRs Permitted to Access the EKS Control Plane via Public Interface"
  type        = list(string)
}

variable "kubernetes_cluster_version" {
  default     = null
  description = "Desired Kubernetes Version to Use When Creating or Updating Kubernetes Cluster"
  type        = string
}

##################################
# Created Resource Configuration #
##################################

variable "resource_tags" {
  default     = {}
  description = "Map of AWS Resource Tags to Assign to All Created Resources"
  type        = map(string)
}
