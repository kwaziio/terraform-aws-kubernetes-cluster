##################################################################
# Creates AWS CloudWatch Log Group for Managing EKS Cluster Logs #
##################################################################

resource "aws_cloudwatch_log_group" "eks_cluster" {
  count             = var.kubernetes_cluster_manage_log_group ? 1 : 0
  kms_key_id        = var.kubernetes_cluster_log_kms_key
  log_group_class   = var.kubernetes_cluster_log_group_class
  name              = "/aws/eks/${var.kubernetes_cluster_name}/cluster"
  retention_in_days = var.kubernetes_cluster_log_retention
  skip_destroy      = var.kubernetes_cluster_retain_logs

  tags = merge({
    Application = "kubernetes"
    Component   = "cluster"
  }, var.resource_tags)
}

########################################################
# Creates AWS Elastic Kubernetes Service (EKS) Cluster #
########################################################

resource "aws_eks_cluster" "main" {
  depends_on                = [aws_cloudwatch_log_group.eks_cluster]
  enabled_cluster_log_types = var.kubernetes_cluster_enabled_logs
  name                      = var.kubernetes_cluster_name
  role_arn                  = var.kubernetes_cluster_role_arn
  version                   = var.kubernetes_cluster_version

  kubernetes_network_config {
    ip_family = "ipv4"
    service_ipv4_cidr = var.kubernetes_cluster_cidr
  }

  tags = merge({
    Application = "kubernetes"
    Component   = "cluster"
  }, var.resource_tags)

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = length(var.kubernetes_cluster_trusted_cidrs) > 0
    public_access_cidrs     = var.kubernetes_cluster_trusted_cidrs
    security_group_ids      = var.kubernetes_cluster_firewall_ids
    subnet_ids              = var.kubernetes_cluster_subnet_ids
  }
}
