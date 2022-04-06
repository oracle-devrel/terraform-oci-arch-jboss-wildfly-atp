## Copyright (c) 2022 Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# ATPSecurityGroup

resource "oci_core_network_security_group" "ATPSecurityGroup" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "ATPSecurityGroup"
  vcn_id         = oci_core_vcn.vcn01[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Rules related to ATPSecurityGroup

# EGRESS

resource "oci_core_network_security_group_security_rule" "ATPSecurityEgressGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.ATPSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS

resource "oci_core_network_security_group_security_rule" "ATPSecurityIngressGroupRules" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.ATPSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 1522
      min = 1522
    }
  }
}

# SSHSecurityGroup

resource "oci_core_network_security_group" "SSHSecurityGroup" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  display_name   = "Bastion_NSG"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# SSHSecurityGroup Rules - EGRESS

resource "oci_core_network_security_group_security_rule" "SSHSecurityEgressGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# SSHSecurityGroup Rules - INGRES

resource "oci_core_network_security_group_security_rule" "SSHSecurityIngressGroupRules" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

# LBSecurityGroup

resource "oci_core_network_security_group" "LBSecurityGroup" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  display_name   = "LB_NSG"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


# LBSecurityGroup Rules - EGRESS

resource "oci_core_network_security_group_security_rule" "LBSecurityEgressInternetGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# LBSecurityGroup Rules - INGRESS

resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules_TCP80" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules_TCP443" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules_TCP9990" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 9990
      min = 9990
    }
  }
}

# JBossSecurityGroup

resource "oci_core_network_security_group" "JBossSecurityGroup" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  display_name   = "APP_NSG"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# EGRESS Rules - JBossSecurityGroup 
resource "oci_core_network_security_group_security_rule" "JBossSecurityEgressATPGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.JBossSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.ATPSecurityGroup[0].id
  destination_type          = "NETWORK_SECURITY_GROUP"
}

resource "oci_core_network_security_group_security_rule" "JBossSecurityEgressGroupRules" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.JBossSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS Rules - JBossSecurityGroup 

resource "oci_core_network_security_group_security_rule" "JBossSecurityIngressGroupRules_TCP80" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.JBossSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "JBossSecurityIngressGroupRules_TCP443" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.JBossSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "JBossSecurityIngressGroupRules_TCP8080" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.JBossSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 8080
      min = 8080
    }
  }
}


resource "oci_core_network_security_group_security_rule" "JBossSecurityIngressGroupRules_TCP9990" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.JBossSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 9990
      min = 9990
    }
  }
}

