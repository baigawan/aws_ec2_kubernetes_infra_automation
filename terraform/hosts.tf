resource "null_resource" "pub_key" {

 provisioner "local-exec" {

    command = "rm -rf keys && mkdir keys && ssh-keygen -b 2048 -t rsa -f keys/${var.ssh_rsa} -q -N ''"
  }
}

resource "local_file" "hosts_cfg" {
  content = templatefile("./templates/hosts.tpl",
    {
      cntrlr = aws_instance.k8-dev.*.public_ip
      wrkr = aws_instance.k8-dev-wrks.*.public_ip
      ssh_user = var.ssh_user
      ssh_rsa = var.ssh_rsa
    }
  )
  filename = "../ansible/inventory/add_key_hosts.cfg"
  depends_on = [
    aws_instance.k8-dev-wrks,
    aws_instance.k8-dev-wrks,
    null_resource.pub_key
  ]
}

resource "null_resource" "install_pub_key_cntrlrs" {
  count         = var.controllers_vm_count
  provisioner "remote-exec" {
    connection {
      host = aws_instance.k8-dev[count.index].public_dns
      user = "ubuntu"
      private_key = file(var.private_key_path)
    }

    inline = ["echo 'Controller connected!'"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook ../ansible/add_keys.yml -i ../ansible/inventory/add_key_hosts.cfg --user ubuntu --key-file ${var.private_key_path} -e 'ssh_rsa=${var.ssh_rsa}' -e 'key=../terraform/keys/${var.ssh_rsa}.pub'"
  }
}

resource "null_resource" "install_pub_key_wrkrs" {
  count         = var.workers_vm_count

  provisioner "remote-exec" {
    connection {
      host = aws_instance.k8-dev-wrks[count.index].public_dns
      user = "ubuntu"
      private_key = file(var.private_key_path)
    }

    inline = ["echo 'Worker connected!'"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook ../ansible/add_keys.yml -i ../ansible/inventory/add_key_hosts.cfg --user ubuntu --key-file ${var.private_key_path} -e 'ssh_rsa=${var.ssh_rsa}' -e 'key=../terraform/keys/${var.ssh_rsa}.pub'"
  }
}

resource "local_file" "ansible_hosts" {
  content = templatefile("./templates/hosts_updated.tpl",
    {
      cntrlr = aws_instance.k8-dev.*.public_ip
      wrkr = aws_instance.k8-dev-wrks.*.public_ip
      ssh_user = var.ssh_user
      ssh_rsa = var.ssh_rsa
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
  depends_on = [
    local_file.hosts_cfg,
    null_resource.install_pub_key_cntrlrs,
    null_resource.install_pub_key_wrkrs
  ]
}