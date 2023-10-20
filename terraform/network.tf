resource "aws_vpc" "sm-kubernetes-proj" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "sm-kubernetes-proj"
  }
}

resource "aws_subnet" "kubernetes-pvt" {
  vpc_id     = aws_vpc.sm-kubernetes-proj.id
  cidr_block = var.subnet_cidr_block

  tags = {
    Name = "kubernetes-pvt"
  }
}

resource "aws_internet_gateway" "kubernetes-igw" {
  vpc_id = aws_vpc.sm-kubernetes-proj.id

  tags = {
    Name = "kubernetes-igw"
  }
}

resource "aws_route_table" "sm-k8s-rt" {
  vpc_id = aws_vpc.sm-kubernetes-proj.id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.kubernetes-igw.id
  }

  tags = {
    Name = "sm-k8s-routing-table"
  }
}

resource "aws_route_table_association" "sm-rt-asc" {
  subnet_id      = aws_subnet.kubernetes-pvt.id
  route_table_id = aws_route_table.sm-k8s-rt.id
}

resource "aws_route" "sm-route" {
  route_table_id            = aws_route_table.sm-k8s-rt.id
  destination_cidr_block    = var.rt_cidr_block
  gateway_id = aws_internet_gateway.kubernetes-igw.id
}

resource "aws_security_group" "sm-kubernetes-proj" {
  name        = "sm-kubernetes-proj"
  description = "Allow ssh and rmate inbound traffic"
  vpc_id      = aws_vpc.sm-kubernetes-proj.id

  tags = {
    Name = "kubernetes-sg"
  }
}


resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = [var.ingress_rules[count.index].cidr_block]
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.sm-kubernetes-proj.id

}

resource "aws_security_group_rule" "egress_rules" {
  count = length(var.egress_rules)

  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = [var.egress_rules[count.index].cidr_block]
  description       = var.egress_rules[count.index].description
  security_group_id = aws_security_group.sm-kubernetes-proj.id
}

resource "aws_lb" "kubernetes-nlb" {
  name               = var.lb_name
  internal = false 
  load_balancer_type = "network"
  subnets = [aws_subnet.kubernetes-pvt.id]

}

resource "aws_lb_target_group" "kubernetes-tg" {
  port     = var.kube_port
  protocol = "TCP"
  vpc_id   = aws_vpc.sm-kubernetes-proj.id
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "sm-tg-rgstr" {
  count = var.controllers_vm_count
  target_group_arn = aws_lb_target_group.kubernetes-tg.arn
  target_id        =  var.cntrls_private_ip[count.index]
  
}

resource "aws_lb_listener" "sm-lb-lstn" {
  load_balancer_arn = aws_lb.kubernetes-nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubernetes-tg.arn
  }

  depends_on = [ aws_instance.k8-dev-wrks ]
}