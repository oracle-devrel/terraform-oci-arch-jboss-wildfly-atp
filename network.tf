## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn01" {
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = var.vcn01_cidr_block
  dns_label      = var.vcn01_dns_label
  compartment_id = var.compartment_ocid
  display_name   = var.vcn01_display_name
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#IGW
resource "oci_core_internet_gateway" "vcn01_internet_gateway" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  enabled        = "true"
  display_name   = "IGW_vcn01"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_nat_gateway" "vcn01_nat_gateway" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  display_name   = "NAT_GW_vcn01"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#Default route table vcn01
resource "oci_core_default_route_table" "vcn01_default_route_table" {
  count                      = !var.use_existing_vcn ? 1 : 0
  manage_default_resource_id = oci_core_vcn.vcn01[0].default_route_table_id
  route_rules {
    network_entity_id = oci_core_internet_gateway.vcn01_internet_gateway[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#Default security list
resource "oci_core_default_security_list" "vcn01_default_security_list" {
  count                      = !var.use_existing_vcn ? 1 : 0
  manage_default_resource_id = oci_core_vcn.vcn01[0].default_security_list_id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "vnc01_nat_route_table" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  display_name   = "NAT_RT"
  route_rules {
    network_entity_id = oci_core_nat_gateway.vcn01_nat_gateway[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


#vcn01 bastion subnet
resource "oci_core_subnet" "vcn01_subnet_bastion" {
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = var.vcn01_subnet_bastion_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  dns_label      = "bassub"
  display_name   = var.vcn01_subnet_bastion_display_name
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#vcn01 loadbalancer subnet
resource "oci_core_subnet" "vcn01_subnet_lb" {
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = var.vcn01_subnet_lb_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  display_name   = var.vcn01_subnet_lb_display_name
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#vcn01 jboss subnet
resource "oci_core_subnet" "vcn01_subnet_jboss" {
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = var.vcn01_subnet_jboss_cidr_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn01[0].id
  dns_label                  = "jbosub"
  display_name               = var.vcn01_subnet_jboss_display_name
  prohibit_public_ip_on_vnic = true
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table_attachment" "vcn01_subnet_jboss_route_table_attachment" {
  count          = !var.use_existing_vcn ? 1 : 0
  subnet_id      = oci_core_subnet.vcn01_subnet_jboss[0].id
  route_table_id = oci_core_route_table.vnc01_nat_route_table[0].id
}


#vcn01 db01 subnet
resource "oci_core_subnet" "vcn01_subnet_atp" {
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = var.vcn01_subnet_atp_cidr_block
  compartment_id             = var.compartment_ocid
  dns_label                  = "adbsub"
  vcn_id                     = oci_core_vcn.vcn01[0].id
  display_name               = var.vcn01_subnet_atp_display_name
  prohibit_public_ip_on_vnic = true
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table_attachment" "vcn01_subnet_atp_route_table_attachment" {
  count          = !var.use_existing_vcn ? 1 : 0
  subnet_id      = oci_core_subnet.vcn01_subnet_atp[0].id
  route_table_id = oci_core_route_table.vnc01_nat_route_table[0].id
}

