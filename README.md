# aws_ec2_kubernetes_infra_automation
To create Kubernetes infrastructure on AWS EC2 instances using Terraform and Ansible

# Summary:
This code is developed for creating a production like Kubernetes infrastructure and driven by Terraform variables. 
If the requirements are in place, it is a two step process to standup k8s environment in AWS. 
Terraform not only builds the resources for K8s but also sets up newly created hosts for Ansible to build them so user doesn't have to worry about maintaining Ansible variables. The steps to access remote cluster from local machine have been also added to the playbook along with installing Kubernetes dashboard. User can lookup the dashboard URL and Token in the very last task executed by the Ansible playbook (also mentioned as Optional in the Usage Example section).


It was a motivation for creating my personal test environment to build and destroy without worrying about maintaining long bash scripts.
Configurations were followed from https://medium.com/geekculture/building-a-kubernetes-cluster-on-aws-from-scratch-7e1e8b0342c4

# Requirements:
- Terrform
- Ansible
- AWS account
- AWS CLI Authenticated
- cfssl and cfssljon
  - https://github.com/cloudflare/cfssl
- kubectl 
- ansible-galaxy collection install kubernetes.core
- pip3 install kubernetes

# Usage Example:
Initialize Terraform 
terraform init -reconfigure --var-file environments/dev/terraform.tfvars -backend-config=environments/dev/backend.conf 
- Step 1.
  terraform apply --var-file environments/dev/terraform.tfvars
- Step 2.
  ansible-playbook -i inventory/hosts.cfg main.yml 
- Optional.
  ansible-playbook -i inventory/hosts.cfg main.yml --skip-tags build_nodes
  This will setup local environment to access remote kubernetes cluster and builds up Kubernetes dashboard. This is useful if the session has expired and user needs to setup local env to access the k8s cluster and skipping the nodes build tasks.

