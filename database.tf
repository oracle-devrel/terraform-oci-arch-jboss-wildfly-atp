## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

################
# ATP database #
################

module "terraform-oci-adb" {
  source                                = "github.com/oracle-devrel/terraform-oci-arch-adb"
  adb_password                          = var.atp_admin_password
  compartment_ocid                      = var.compartment_ocid
  adb_database_cpu_core_count           = var.atp_cpu_core_count
  adb_database_data_storage_size_in_tbs = var.atp_storage_tbs
  adb_database_db_name                  = var.atp_db_name
  adb_database_display_name             = var.atp_display_name
  is_auto_scaling_enabled               = var.atp_autoscaling
  adb_database_db_workload              = "OLTP"
  use_existing_vcn                      = var.atp_private_endpoint
  adb_private_endpoint                  = var.atp_private_endpoint
  vcn_id                                = var.atp_private_endpoint ? local.vcn_id : null
  adb_nsg_id                            = var.atp_private_endpoint ? local.atp_nsg_id : null
  adb_private_endpoint_label            = var.atp_private_endpoint ? var.atp_private_endpoint_label : null
  adb_subnet_id                         = var.atp_private_endpoint ? local.atp_subnet_id : null
  defined_tags                          = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

