# テンプレート VM（ID: 9000）が存在しない場合のみ作成する
resource "null_resource" "ubuntu_template" {
  triggers = {
    template_id = var.template_id
  }

  connection {
    type        = "ssh"
    host        = var.proxmox_host_ip
    user        = "root"
    private_key = file(pathexpand(var.proxmox_ssh_key))
  }

  provisioner "file" {
    source      = "${path.module}/scripts/create-template.sh"
    destination = "/tmp/create-template.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create-template.sh",
      "/tmp/create-template.sh ${var.template_id} ${var.storage}",
    ]
  }
}

resource "proxmox_virtual_environment_vm" "k8s_node" {
  for_each   = var.nodes
  depends_on = [null_resource.ubuntu_template]

  name      = each.key
  node_name = "pve"
  vm_id     = each.value.vm_id
  tags      = ["lovelab", "k8s", each.value.role]

  clone {
    vm_id = var.template_id
    full  = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = var.storage
    size         = 50
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = [var.nameserver]
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init[each.key].id
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init" {
  for_each     = var.nodes
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = templatefile("${path.module}/cloud-init/user-data.yaml.tpl", {
      hostname = each.key
    })
    file_name = "user-data-${each.key}.yaml"
  }
}
