###############################
# Locally-Available Variables #
###############################

locals {
  aws_auth_role_map = concat(
    var.aws_auth_roles,
    [for arn in var.aws_auth_role_nodes : {
      rolearn  = arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "eks:kube-proxy-windows",
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier",
      ]
    }],
    [for arn in var.aws_auth_role_owners : {
      rolearn  = arn
      username = "owner"
      groups   = [
        "system:masters",
      ]
    }],
  )
}

#########################################################################
# Creates AWS Authentication Configuration Map (if NOT Already Present) #
#########################################################################

resource "kubernetes_config_map_v1" "aws_auth" {
  data = {
    mapAccounts = yamlencode(var.aws_auth_accounts)
    mapRoles    = yamlencode(local.aws_auth_role_map)
    mapUsers    = yamlencode(var.aws_auth_users)
  }

  lifecycle {
    ignore_changes = [
      data,
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

#####################################################
# Updates AWS Authentication Configuration Map Data #
#####################################################

resource "kubernetes_config_map_v1_data" "aws_auth" {
  depends_on = [kubernetes_config_map_v1.aws_auth]
  force      = true
  
  data = {
    mapAccounts = yamlencode(var.aws_auth_accounts)
    mapRoles    = yamlencode(local.aws_auth_role_map)
    mapUsers    = yamlencode(var.aws_auth_users)
  }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}
