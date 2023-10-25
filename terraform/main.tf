resource "aws_instance" "k8-dev" {
  count         = var.controllers_vm_count
  ami           =  var.ami_name
  instance_type = var.instance_type

  user_data = "name=${var.cntrls_prefix}-${count.index}"
  private_ip = var.cntrls_private_ip[count.index]
  associate_public_ip_address = true

  vpc_security_group_ids=[aws_security_group.sm-kubernetes-proj.id]
  subnet_id = aws_subnet.kubernetes-pvt.id
  key_name = var.rsa_key_name

  source_dest_check = false

  root_block_device {
    volume_size = var.boot_disk_size
    volume_type = var.volume_type
  }

  tags = {
    Name = "${var.cntrls_prefix}-${count.index}"
  }
  
}

resource "aws_instance" "k8-dev-wrks" {
  count         = var.workers_vm_count
  ami           = var.ami_name
  instance_type = var.instance_type

  user_data = "name=${var.wrkrs_prefix}-${count.index}|pod-cidr=${var.pod_cidr_blocks[count.index]}"
  private_ip = var.wrkrs_private_ip[count.index]
  associate_public_ip_address = true

  vpc_security_group_ids=[aws_security_group.sm-kubernetes-proj.id]
  subnet_id = aws_subnet.kubernetes-pvt.id
  key_name = var.rsa_key_name


  source_dest_check = false

  root_block_device {
    volume_size = var.boot_disk_size
    volume_type = var.volume_type
  }

  tags = {
    Name = "${var.wrkrs_prefix}-${count.index}"
  }
  
}