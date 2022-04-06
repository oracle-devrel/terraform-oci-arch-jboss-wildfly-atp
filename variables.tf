## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
variable "fingerprint" {}
variable "user_ocid" {}
variable "private_key_path" {}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.2"
}

variable "numberOfNodes" {
  default = 2
}

variable "availability_domain_name" {
  default = ""
}
variable "availability_domain_number" {
  default = 0
}

variable "ssh_public_key" {
  default = ""
}

variable "use_existing_vcn" {
  default = false
}

variable "use_existing_nsg" {
  default = false
}

variable "vcn_id" {
  default = ""
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "lb_subnet_id" {
  default = ""
}

variable "lb_nsg_ids" {
  default = []
}

variable "compute_subnet_id" {
  default = ""
}

variable "compute_nsg_ids" {
  default = []
}

variable "atp_subnet_id" {
  default = ""
}

variable "atp_nsg_id" {
  default = ""
}

variable "bastion_subnet_id" {
  default = ""
}

variable "bastion_nsg_ids" {
  default = []
}

variable "use_bastion_service" {
  default = false
}

variable "igw_display_name" {
  default = "internet-gateway"
}

variable "InstanceShape" {
  default = "VM.Standard.E4.Flex"
}

variable "InstanceFlexShapeOCPUS" {
  default = 1
}

variable "InstanceFlexShapeMemory" {
  default = 10
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "prefix" {
  default = "jboss"
}

variable "jboss_admin_username" {
  default = "admin"
}
variable "jboss_admin_password" {
  type = string
}

variable "jboss_display_name" {
  default = "jboss"
}

variable "create_ds" {
  type = bool
  default = true
}

# Bastion
variable "bastion_vm_shape" {
  default = "VM.Standard.E4.Flex"
}

variable "bastion_vm_flex_shape_ocpu" {
  default = 1
}

variable "bastion_vm_flex_shape_mem" {
  default = 1
}

# ATP
variable "provision_atp" {
  type    = bool
  default = true
}

variable "atp_private_endpoint" {
  default = true
}

variable "atp_private_endpoint_label" {
  default = "JBossATPPE"
}

variable "atp_admin_password" {
  type    = string
  default = ""
}

variable "atp_display_name" {
  type    = string
  default = "JBossATP"
}

variable "atp_db_name" {
  type    = string
  default = "JBossATP"
}

variable "atp_cpu_core_count" {
  type    = number
  default = 1
}

variable "atp_storage_tbs" {
  type    = number
  default = 1
}

variable "atp_autoscaling" {
  type    = bool
  default = false
}

variable "atp_tde_wallet_zip_file" {
  default = "tde_wallet_JBossATP.zip"
}

variable "ds_name" {
  type    = string
  default = "OracleDS"
}

variable "atp_username" {
  type    = string
  default = ""
}

variable "atp_password" {
  type    = string
  default = ""
}

variable "domain_mode" {
  type    = bool
  default = true
}

variable "vcn01_cidr_block" {
  default = "10.0.0.0/16"
}
variable "vcn01_dns_label" {
  default = "vcn01"
}
variable "vcn01_display_name" {
  default = "vcn01"
}

variable "vcn01_subnet_lb_cidr_block" {
  default = "10.0.1.0/24"
}

variable "vcn01_subnet_lb_display_name" {
  default = "vcn01_subnet_lb"
}

variable "vcn01_subnet_bastion_cidr_block" {
  default = "10.0.2.0/24"
}

variable "vcn01_subnet_bastion_display_name" {
  default = "vcn01_subnet_bastion"
}

variable "vcn01_subnet_jboss_cidr_block" {
  default = "10.0.10.0/24"
}

variable "vcn01_subnet_jboss_display_name" {
  default = "vcn01_subnet_jboss"
}

variable "vcn01_subnet_atp_cidr_block" {
  default = "10.0.20.0/24"
}

variable "vcn01_subnet_atp_display_name" {
  default = "vcn01_subnet_atp"
}

# locals
locals {
  hostname_label  = replace(lower(var.jboss_display_name), " ", "")
  atp_nsg_id      = !var.use_existing_nsg ? oci_core_network_security_group.ATPSecurityGroup[0].id : var.atp_nsg_id
  atp_subnet_id   = !var.use_existing_vcn ? oci_core_subnet.vcn01_subnet_atp[0].id : var.atp_subnet_id
  vcn_id          = !var.use_existing_vcn ? oci_core_vcn.vcn01[0].id : var.vcn_id
}
