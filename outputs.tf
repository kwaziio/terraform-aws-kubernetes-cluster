#############################################################
# Provides Information for AWS Authentication Configuration #
#############################################################

output "aws_auth_data" {
  description = "Kubernetes AWS Authentication Configuration Map Data"
  value       = yamlencode(kubernetes_config_map_v1_data.aws_auth.data)
}

################################################################################
# Provides Information for Kubernetes Cluster Resources Created by this Module #
################################################################################

output "cluster_ca_certificate" {
  description = "Kubernetes Certificate Authority (CA) Certificate"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_log_group" {
  description = "Name of the AWS CloudWatch Log Group for Accessing Control Plane Logs"
  value       = aws_cloudwatch_log_group.eks_cluster.name
}

output "cluster_name" {
  description = "Name Assigned to the AWS Elastic Kubernetes Service (EKS) Cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint (Host) Required to Interact with Kubernetes Cluster API"
  value       = aws_eks_cluster.main.endpoint
}

##################################################################################
# Provides Information for AWS VPC [Network] Resources Associated w/ this Module #
##################################################################################

output "network_id" {
  description = "ID of the Virtual Private Cloud (VPC) [Network] Assocated w/ this Cluster"
  value       = coalesce(var.kubernetes_cluster_network_id, data.aws_vpcs.selected[0].ids[0])
}

###############################################################################
# Provides Information for AWS VPC Subnet Resources Associated w/ this Module #
###############################################################################

output "subnet_ids" {
  description = "ID of the Virtual Private Cloud (VPC) Subnets Associated w/ this Cluster"
  value       = coalesce(var.kubernetes_cluster_subnet_ids, data.aws_subnets.private[0].ids)
}
