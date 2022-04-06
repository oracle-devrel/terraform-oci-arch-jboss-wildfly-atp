## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Checks if is using Flexible LB Shapes
locals {
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}

resource "oci_load_balancer" "lb_jboss" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = var.compartment_ocid

  subnet_ids = [
    !var.use_existing_vcn ? oci_core_subnet.vcn01_subnet_lb[0].id : var.lb_subnet_id,
  ]

  display_name               = "lb_jboss"
  network_security_group_ids = !var.use_existing_nsg ? [oci_core_network_security_group.LBSecurityGroup[0].id] : var.lb_nsg_ids

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_load_balancer_backend_set" "lb_backend_jboss" {
  name             = "lb_backend_jboss"
  load_balancer_id = oci_load_balancer.lb_jboss.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "8080"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    interval_ms         = "10000"
    return_code         = "200"
    timeout_in_millis   = "3000"
    retries             = "3"
  }
}

resource "oci_load_balancer_listener" "lb_listener_jboss" {
  load_balancer_id         = oci_load_balancer.lb_jboss.id
  name                     = "lb_listener_http_80_jboss"
  default_backend_set_name = oci_load_balancer_backend_set.lb_backend_jboss.name
  port                     = 80
  protocol                 = "HTTP"
}

resource "oci_load_balancer_backend" "lb_be_jboss_8080" {
  count            = var.numberOfNodes
  load_balancer_id = oci_load_balancer.lb_jboss.id
  backendset_name  = oci_load_balancer_backend_set.lb_backend_jboss.name
  ip_address       = oci_core_instance.jboss_server[count.index].private_ip
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
