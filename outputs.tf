################################################################################
# Provides Information for Kubernetes Cluster Resources Created by this Module #
################################################################################

output "cluster_ca_certificate" {
  description = "Kubernetes Certificate Authority (CA) Certificate"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_log_group" {
  description = "Name of the AWS CloudWatch Log Group for Accessing Control Plane Logs"
  value       = var.kubernetes_cluster_manage_log_group ? one(aws_cloudwatch_log_group.eks_cluster).name : null
}

output "cluster_name" {
  description = "Name Assigned to the AWS Elastic Kubernetes Service (EKS) Cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint (Host) Required to Interact with Kubernetes Cluster API"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes Version Used by the Created Kubernetes Cluster"
  value       = aws_eks_cluster.main.version
}

###############################################################################
# Provides Information for AWS VPC Subnet Resources Associated w/ this Module #
###############################################################################

output "subnet_ids" {
  description = "ID of the Virtual Private Cloud (VPC) Subnets Associated w/ this Cluster"
  value       = var.kubernetes_cluster_subnet_ids
}
