## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "jboss_home" {
  value = "http://${oci_load_balancer.lb_jboss.ip_addresses[0]}"
}

output "bastion_public_ip" {
  value = oci_core_instance.bastion_instance.*.public_ip
}

output "bastion_ssh_metadata" {
  value = oci_bastion_session.ssh_via_bastion_service.*.ssh_metadata
}

output "jboss-server_private_ips" {
  value = data.oci_core_vnic.jboss_server_primaryvnic.*.private_ip_address
}

output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

