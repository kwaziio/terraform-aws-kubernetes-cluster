###########################################################################
# Retrieves AWS Identity and Access Management (IAM) Role for EKS Cluster #
###########################################################################

data "aws_iam_role" "eks_cluster" {
  count = var.kubernetes_cluster_role_arn == null ? 1 : 0
  name  = var.kubernetes_cluster_role_name
}

###################################################################
# Retrieves AWS Virtual Private Cloud (VPC) [Network] Information #
###################################################################

data "aws_vpcs" "selected" {
  count = var.kubernetes_cluster_network_id == null ? 1 : 0

  tags = {
    Name = var.kubernetes_cluster_network_name
  }
}

data "aws_vpc" "selected" {
  count = var.kubernetes_cluster_network_id == null ? 1 : 0
  id    = data.aws_vpcs.selected[0].ids[0]
}

##########################################################################
# Retrieves AWS Virtual Private Cloud (VPC) [Network] Subnet Information #
##########################################################################

data "aws_subnets" "private" {
  count = var.kubernetes_cluster_subnet_ids == null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [coalesce(var.kubernetes_cluster_network_id, data.aws_vpcs.selected[0].ids[0])]
  }

  tags = {
    Type = "private"
  }
}

#####################################################################
# Retrieves AWS VPC [Network] Security Group [Firewall] Information #
#####################################################################

data "aws_security_groups" "eks_cluster" {
  count = var.kubernetes_cluster_firewall_ids == null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [coalesce(var.kubernetes_cluster_network_id, data.aws_vpcs.selected[0].ids[0])]
  }

  tags = {
    Application = "kubernetes"
    Component   = "cluster"
    Environment = var.tags_environment
  }
}
