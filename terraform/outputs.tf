output "wrkrs_arts" {
  value = [for v in aws_instance.k8-dev-wrks: {"wrkr_name":v.tags.Name, "external_ip":v.public_ip, "private_ip":v.private_ip}]
}

output "cntrls_arts" {
  value = [for v in aws_instance.k8-dev: {"cntrl_name":v.tags.Name, "external_ip":v.public_ip, "private_ip":v.private_ip}]
}

output "kube_cluster_name" {
  value = {"kube_cluster_name":"${var.env}-${var.kube_cluster_name}"} 
}

output "kbrts_pub_addr" {
  value = {"KUBERNETES_PUBLIC_ADDRESS":aws_lb.kubernetes-nlb.dns_name}
}

output "api_server_ip" {
  value = {"api_server_ip":var.api_server_ip}
}

output "kube_port" {
  value = {"kube_port":var.kube_port}
}

output "cluster_dns" {
  value = {"cluster_dns":var.cluster_dns}
}

output "cluster_cidr" {
  value = {"cluster_cidr":var.cluster_cidr}
}

output "cntrlrs_peer_port" {
  value = {"cntrlrs_peer_port":var.cntrlrs_peer_port}
}

output "etcd_servers_port" {
  value = {"etcd_servers_port":var.etcd_servers_port}
}

output "cluster_ip_range" {
  value = {"cluster_ip_range":var.cluster_ip_range}
}

output "node_port_range" {
  value = {"node_port_range":var.node_port_range}
}

output "cntrls_prefix" {
  value = {"cntrls_prefix":var.cntrls_prefix}
}

output "wrkrs_prefix" {
  value = {"wrkrs_prefix":var.wrkrs_prefix}
}