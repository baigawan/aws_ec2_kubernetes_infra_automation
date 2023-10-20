variable "private_key_path" {
    type = string
}

variable "instance_type" {
 type = string
 default = "t2.micro"
 description = "EC2 instance type"
}

variable "boot_disk_size" {
  type = number
}

variable "env" {
    type = string
}

variable "kube_cluster_name" {
  type = string
}

variable "wrkrs_prefix" {
    type = string
}

variable "cntrls_prefix" {
    type = string
}

variable "volume_type" {
    type = string
    default = "gp2"
}

variable "rsa_key_name" {
    type = string
}

variable "ami_name" {
    type = string
}

variable "security_group_name" {
    type = string
}

variable "dep_region" {
    type = string
}

variable "controllers_vm_count" {
  type = number
}

variable "workers_vm_count" {
  type = number
}

variable "wrkrs_arts" {
  type = list
  default = []
}

variable "wrkrs_private_ip" {
  type = list
}

variable "cntrls_private_ip" {
  type = list
}

variable "cluster_dns" {
  type = string
}

variable "api_server_ip" {
  type = string
}

variable "kube_port" {
  type = string
}

variable "cntrlrs_peer_port" {
  type = string
}

variable "etcd_servers_port" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "rt_cidr_block" {
  type = string
}

variable "cluster_cidr" {
  type = string
}

variable "cluster_ip_range" {
  type = string
}

variable "node_port_range" {
  type = string
}

variable "subnet_cidr_block" {
  type = string
}

variable "pod_cidr_blocks" {
  type = list
}

variable "lb_name" {
  type = string
}

variable "ssh_rsa" {
  type = string
}

variable "ssh_user" {
  type = string
}


variable "default_tags" {
  description = "For self managed K8s cluster"
  type = object({
    Name = string
    class   = string
    purpose = string
  })
}

variable "ingress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
    default     = [
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
        
    ]
}

variable "egress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
    default     = [
        {
          from_port   = 52698
          to_port     = 52698
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "for rmate"
        },
    ]
}
