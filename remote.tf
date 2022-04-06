## Copyright (c) 2021 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "jboss_configure_datasource" {
  count    = var.numberOfNodes
  template = file("${path.module}/scripts/configure_datasource.sh")

  vars = {
    password       = var.atp_password
    username       = var.atp_username
    atp_db_name    = var.atp_db_name
    jboss_username = var.jboss_admin_username
    jboss_password = var.jboss_admin_password
    ds_name        = var.ds_name
    domain_mode    = var.domain_mode ? "domain" : "standalone"
    index          = count.index
    nb_nodes       = var.create_ds ? length(oci_core_instance.jboss_server[*].private_ip) : 0
  }
}

data "template_file" "jboss_configure_driver" {
  count    = var.numberOfNodes
  template = file("${path.module}/scripts/configure_driver.sh")

  vars = {
    jboss_username = var.jboss_admin_username,
    jboss_password = var.jboss_admin_password,
    domain_mode    = var.domain_mode ? "domain" : "standalone"
    index          = count.index
    nb_nodes       = length(oci_core_instance.jboss_server[*].private_ip)
  }

}

resource "null_resource" "jboss_provisioning" {
  depends_on = [oci_core_instance.jboss_server, module.terraform-oci-adb.adb_database]
  count      = var.numberOfNodes

  triggers = {
    instance_ids = join(",", oci_core_instance.jboss_server[*].private_ip)
    domain_mode = var.domain_mode
  }

  provisioner "local-exec" {
    command = "echo '${module.terraform-oci-adb.adb_database.adb_wallet_content}' >> ${var.atp_tde_wallet_zip_file}_encoded-${count.index}"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${var.atp_tde_wallet_zip_file}_encoded-${count.index} > ${var.atp_tde_wallet_zip_file}-${count.index}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.atp_tde_wallet_zip_file}_encoded-${count.index}"
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    source      = "${var.atp_tde_wallet_zip_file}-${count.index}"
    destination = "/tmp/${var.atp_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.atp_tde_wallet_zip_file}-${count.index}"
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = file("${path.module}/scripts/module.xml")
    destination = "/home/opc/module.xml"
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = file("${path.module}/scripts/setup_jboss.sh")
    destination = "/home/opc/setup_jboss.sh"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "echo 'Starting JBoss setup... '",
      "chmod +x /home/opc/setup_jboss.sh",
      "sudo /home/opc/setup_jboss.sh",
      "echo 'JBoss setup finished.'"
    ]
  }

  # Admin console login
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
        "echo 'Configure Admin console...'",
        "sudo su - -c \"/opt/wildfly/bin/add-user.sh -u ${var.jboss_admin_username} -r ManagementRealm -p \"${var.jboss_admin_password}\"\"",
        "echo 'Admin console ready.'",
    ]
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = file("${path.module}/scripts/domain_controller.sh")
    destination = "/home/opc/domain_controller.sh"
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = file("${path.module}/scripts/hostm.xml")
    destination = "/home/opc/hostm.xml"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
        "${var.domain_mode} && echo 'Configure Domain controller'",
        "while [ ! -f /opt/wildfly/bin/add-user.sh ]; do sleep 5; done",
        "chmod +x /home/opc/domain_controller.sh",        
        "${var.domain_mode} && sudo su - -c '/home/opc/domain_controller.sh'",
        "echo 'Domain controller ready.'"
    ]
  }

  provisioner "file" {
      connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    content = data.template_file.jboss_configure_driver[count.index].rendered
    destination = "/home/opc/configure_driver.sh"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    inline = [
      "echo 'Configuring JDBC driver'",
      "sudo su - -c 'chmod +x /home/opc/configure_driver.sh'",
      "sudo su - -c '/home/opc/configure_driver.sh'",
      "echo 'JDBC driver configured.'",
    ]
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.jboss_configure_datasource[count.index].rendered
    destination = "/home/opc/configure_datasource.sh"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.jboss_server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    inline = [
      "${var.create_ds} && echo 'Configuring Datasource'",
      "sudo su - -c 'chmod +x /home/opc/configure_datasource.sh'",
      "${var.create_ds} && sudo su - -c '/home/opc/configure_datasource.sh'",
      "echo 'Datasource configured.'"
    ]
  }

}


