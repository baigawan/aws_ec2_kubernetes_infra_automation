[controller_nodes]
%{ for ip in cntrlr ~}
${ip} ansible_user=${ssh_user}
%{ endfor ~}

[controller_nodes:vars]
ansible_ssh_common_args="-o StrictHostKeyChecking=no"

[worker_nodes]
%{ for ip in wrkr ~}
${ip} ansible_user=${ssh_user}
%{ endfor ~}

[worker_nodes:vars]
ansible_ssh_common_args="-o StrictHostKeyChecking=no"