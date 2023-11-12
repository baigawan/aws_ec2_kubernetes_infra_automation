env = "dev"
ssh_rsa = "my_machine"
ssh_user="ubuntu"
private_key_path="~/.ssh/MY_AWS_KEY.pem"



instance_type = "t3.micro"
ami_name = "ami-0c65adc9a5c1b5d7c"
volume_type = "gp2"
rsa_key_name = "MY_AWS_KEY"
boot_disk_size = 60

dep_region = "us-west-2"
zone = "us-west-2a"

controllers_vm_count = 3
workers_vm_count = 3
security_group_name = "sm-dev-sg"
default_tags = {
  Name = "sm-k8s-dev"
  class   = "sm_test_dev"
  purpose = "k8s_temp_cluster"
}

lb_name           = "kubernetes-nlb"
kube_cluster_name = "sm-kubernetes"
wrkrs_prefix      = "worker"
cntrls_prefix     = "controller"

kube_port         = 6443
cntrlrs_peer_port = 2380
etcd_servers_port = 2379

rt_cidr_block     = "0.0.0.0/0"
vpc_cidr_block    = "10.0.0.0/16"
subnet_cidr_block = "10.0.1.0/24"

api_server_ip     = "10.32.0.1"
cluster_dns       = "10.32.0.10"
cluster_cidr      = "10.200.0.0/16"
cluster_ip_range  = "10.32.0.0/24"
node_port_range   = "30000-32767"

pod_cidr_blocks   = ["10.200.0.0/24","10.200.1.0/24","10.200.2.0/24"]
wrkrs_private_ip  = ["10.0.1.20","10.0.1.21","10.0.1.22"]
cntrls_private_ip = ["10.0.1.10","10.0.1.11","10.0.1.12"]

ingress_rules = [
        {
          from_port   = -1
          to_port     = -1
          protocol    = "-1"
          cidr_block  = "10.0.0.0/16"
          description = "for all"
        },
        {
          from_port   = -1
          to_port     = -1
          protocol    = "-1"
          cidr_block  = "10.200.0.0/16"
          description = "for all"
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "for ssh"
        },
        {
          from_port   = 52698
          to_port     = 52698
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "for rmate"
        },
        {
          from_port   = 6443
          to_port     = 6443
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "Kubernetes API server"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "just https access"
        },
        {
          from_port   = -1
          to_port     = -1
          protocol    = "icmp"
          cidr_block  = "0.0.0.0/0"
          description = "status check, ping"
        },
    ]

egress_rules = [
        {
          from_port   = -1
          to_port     = -1
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
          description = "for all"
        },
    ]