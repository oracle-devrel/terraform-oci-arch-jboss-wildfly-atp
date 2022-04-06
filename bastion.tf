## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_bastion_bastion" "bastion-service" {
  count                        = var.use_bastion_service ? 1 : 0
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = !var.use_existing_vcn ? oci_core_subnet.vcn01_subnet_jboss[0].id : var.compute_subnet_id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  defined_tags                 = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  name                         = "BastionService"
  max_session_ttl_in_seconds   = 1800
}

resource "oci_bastion_session" "ssh_via_bastion_service" {
  depends_on = [oci_core_instance.jboss_server,
    oci_core_nat_gateway.vcn01_nat_gateway,
    oci_core_route_table_attachment.vcn01_subnet_jboss_route_table_attachment,
    oci_core_route_table.vnc01_nat_route_table,
    oci_core_network_security_group.SSHSecurityGroup,
    oci_core_network_security_group_security_rule.SSHSecurityEgressGroupRule,
    oci_core_network_security_group_security_rule.SSHSecurityIngressGroupRules
  ]

  count      = var.use_bastion_service ? var.numberOfNodes : 0
  bastion_id = oci_bastion_bastion.bastion-service[0].id

  key_details {
    public_key_content = tls_private_key.public_private_key_pair.public_key_openssh
  }
  target_resource_details {
    session_type       = "MANAGED_SSH"
    target_resource_id = oci_core_instance.jboss_server[count.index].id

    #Optional
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.jboss_server[count.index].private_ip
  }

  display_name           = "ssh_via_bastion_service"
  key_type               = "PUB"
  session_ttl_in_seconds = 1800
}


resource "oci_core_instance" "bastion_instance" {
  count               = var.use_bastion_service ? 0 : 1
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "BastionVM"
  shape               = var.InstanceShape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.InstanceFlexShapeMemory
      ocpus         = var.InstanceFlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = !var.use_existing_vcn ? oci_core_subnet.vcn01_subnet_bastion[0].id : var.bastion_subnet_id
    display_name     = "bastion"
    assign_public_ip = true
    nsg_ids          = !var.use_existing_nsg ? [oci_core_network_security_group.SSHSecurityGroup[0].id] : var.bastion_nsg_ids
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


