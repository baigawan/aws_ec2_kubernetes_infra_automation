# aws_ec2_kubernetes_infra_automation
To create Kubernetes infrastructure on AWS EC2 instances using Terraform and Ansible

# Summary:
This code is developed for creating a production like Kubernetes infrastructure and driven by Terraform variables. 
If the requirements are in place, it is a two step process to standup k8s environment in AWS. 
Terraform not only builds the resources for K8s but also sets up newly created hosts for Ansible to build them so user doesn't have to worry about maintaining Ansible variables.

It was a motovation for creating my personal test environment to build and destroy without worrying about maintaining long bash scripts.
Configurations were followed from https://medium.com/geekculture/building-a-kubernetes-cluster-on-aws-from-scratch-7e1e8b0342c4

# Requirements:
- Terrform
- Ansible
- AWS account
- AWS CLI Authenticated
- cfssl and cfssljon
  - https://github.com/cloudflare/cfssl
- kubectl 

# Usage Example:
Initialize Terraform 
terraform init -reconfigure --var-file environments/dev/terraform.tfvars -backend-config=environments/dev/backend.conf 
- Step 1.
  terraform apply --var-file environments/dev/terraform.tfvars
- Step 2.
  ansible-playbook -i inventory/hosts.cfg main.yml 


# Remote access configuration on local machine
KUBERNETES_PUBLIC_ADDRESS=<AWS_LB>

kubectl config set-cluster <KUBERNETES_CLUSTER_NAME> \
  --certificate-authority=certs/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:443
kubectl config set-credentials admin \
  --client-certificate=certs/admin.pem \
  --client-key=certs/admin-key.pem
kubectl config set-context <KUBERNETES_CLUSTER_NAME> \
  --cluster=<KUBERNETES_CLUSTER_NAME> \
  --user=admin
kubectl config use-context <KUBERNETES_CLUSTER_NAME>
