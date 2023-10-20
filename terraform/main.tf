
# resource "aws_vpc" "sm-kubernetes-proj" {
#   cidr_block = var.vpc_cidr_block
#   enable_dns_support = true
#   enable_dns_hostnames = true
#   tags = {
#     Name = "sm-kubernetes-proj"
#   }
# }

# resource "aws_subnet" "kubernetes-pvt" {
#   vpc_id     = aws_vpc.sm-kubernetes-proj.id
#   cidr_block = var.subnet_cidr_block

#   tags = {
#     Name = "kubernetes-pvt"
#   }
# }

# resource "aws_internet_gateway" "kubernetes-igw" {
#   vpc_id = aws_vpc.sm-kubernetes-proj.id

#   tags = {
#     Name = "kubernetes-igw"
#   }
# }

# resource "aws_route_table" "sm-k8s-rt" {
#   vpc_id = aws_vpc.sm-kubernetes-proj.id

#   route {
#     cidr_block = var.rt_cidr_block
#     gateway_id = aws_internet_gateway.kubernetes-igw.id
#   }

#   tags = {
#     Name = "sm-k8s-routing-table"
#   }
# }

# resource "aws_route_table_association" "sm-rt-asc" {
#   subnet_id      = aws_subnet.kubernetes-pvt.id
#   route_table_id = aws_route_table.sm-k8s-rt.id
# }

# resource "aws_route" "sm-route" {
#   route_table_id            = aws_route_table.sm-k8s-rt.id
#   destination_cidr_block    = var.rt_cidr_block
#   gateway_id = aws_internet_gateway.kubernetes-igw.id
# }

# resource "aws_security_group" "sm-kubernetes-proj" {
#   name        = "sm-kubernetes-proj"
#   description = "Allow ssh and rmate inbound traffic"
#   vpc_id      = aws_vpc.sm-kubernetes-proj.id

#   tags = {
#     Name = "kubernetes-sg"
#   }
# }


# resource "aws_security_group_rule" "ingress_rules" {
#   count = length(var.ingress_rules)

#   type              = "ingress"
#   from_port         = var.ingress_rules[count.index].from_port
#   to_port           = var.ingress_rules[count.index].to_port
#   protocol          = var.ingress_rules[count.index].protocol
#   cidr_blocks       = [var.ingress_rules[count.index].cidr_block]
#   description       = var.ingress_rules[count.index].description
#   security_group_id = aws_security_group.sm-kubernetes-proj.id

# }

# resource "aws_security_group_rule" "egress_rules" {
#   count = length(var.egress_rules)

#   type              = "egress"
#   from_port         = var.egress_rules[count.index].from_port
#   to_port           = var.egress_rules[count.index].to_port
#   protocol          = var.egress_rules[count.index].protocol
#   cidr_blocks       = [var.egress_rules[count.index].cidr_block]
#   description       = var.egress_rules[count.index].description
#   security_group_id = aws_security_group.sm-kubernetes-proj.id
# }

# resource "aws_lb" "kubernetes-nlb" {
#   name               = var.lb_name
#   internal = false 
#   load_balancer_type = "network"
#   subnets = [aws_subnet.kubernetes-pvt.id]

# }

# resource "aws_lb_target_group" "kubernetes-tg" {
#   port     = var.kube_port
#   protocol = "TCP"
#   vpc_id   = aws_vpc.sm-kubernetes-proj.id
#   target_type = "ip"
# }

# resource "aws_lb_target_group_attachment" "sm-tg-rgstr" {
#   count = var.controllers_vm_count
#   target_group_arn = aws_lb_target_group.kubernetes-tg.arn
#   target_id        =  var.cntrls_private_ip[count.index]
  
# }

# resource "aws_lb_listener" "sm-lb-lstn" {
#   load_balancer_arn = aws_lb.kubernetes-nlb.arn
#   port              = "443"
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.kubernetes-tg.arn
#   }

#   depends_on = [ aws_instance.k8-dev-wrks ]
# }

#########################################
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

#########################################

# resource "null_resource" "pub_key" {

#  provisioner "local-exec" {

#     command = "rm -rf keys && mkdir keys && ssh-keygen -b 2048 -t rsa -f keys/${var.ssh_rsa} -q -N ''"
#   }
# }

# resource "local_file" "hosts_cfg" {
#   content = templatefile("./templates/hosts.tpl",
#     {
#       cntrlr = aws_instance.k8-dev.*.public_ip
#       wrkr = aws_instance.k8-dev-wrks.*.public_ip
#       ssh_user = var.ssh_user
#       ssh_rsa = var.ssh_rsa
#     }
#   )
#   filename = "../ansible/inventory/add_key_hosts.cfg"
#   depends_on = [
#     aws_instance.k8-dev-wrks,
#     aws_instance.k8-dev-wrks,
#     null_resource.pub_key
#   ]
# }

# resource "null_resource" "install_pub_key_cntrlrs" {
#   count         = var.controllers_vm_count
#   provisioner "remote-exec" {
#     connection {
#       host = aws_instance.k8-dev[count.index].public_dns
#       user = "ubuntu"
#       private_key = file(var.private_key_path)
#     }

#     inline = ["echo 'Controller connected!'"]
#   }

#   provisioner "local-exec" {
#     command = "ansible-playbook ../ansible/add_keys.yml -i ../ansible/inventory/add_key_hosts.cfg --user ubuntu --key-file ${var.private_key_path} -e 'key=../terraform/keys/${var.ssh_rsa}.pub'"
#   }
# }

# resource "null_resource" "install_pub_key_wrkrs" {
#   count         = var.workers_vm_count

#   provisioner "remote-exec" {
#     connection {
#       host = aws_instance.k8-dev-wrks[count.index].public_dns
#       user = "ubuntu"
#       private_key = file(var.private_key_path)
#     }

#     inline = ["echo 'Worker connected!'"]
#   }

#   provisioner "local-exec" {
#     command = "ansible-playbook ../ansible/add_keys.yml -i ../ansible/inventory/add_key_hosts.cfg --user ubuntu --key-file ${var.private_key_path} -e 'key=../terraform/keys/${var.ssh_rsa}.pub'"
#   }
# }

# resource "local_file" "ansible_hosts" {
#   content = templatefile("./templates/hosts_updated.tpl",
#     {
#       cntrlr = aws_instance.k8-dev.*.public_ip
#       wrkr = aws_instance.k8-dev-wrks.*.public_ip
#       ssh_user = var.ssh_user
#       ssh_rsa = var.ssh_rsa
#     }
#   )
#   filename = "../ansible/inventory/hosts.cfg"
#   depends_on = [
#     local_file.hosts_cfg,
#     null_resource.install_pub_key_cntrlrs,
#     null_resource.install_pub_key_wrkrs
#   ]
# }