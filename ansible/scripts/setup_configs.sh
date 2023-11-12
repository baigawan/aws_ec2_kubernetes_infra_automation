eval "wrkrs_names=(${wrkrs_names_ar})"
eval "worker_ips=(${worker_ips})"
eval "worker_ext_ips=(${worker_ext_ips})"

eval "cntrls_names=(${cntrls_names_ar})"
eval "cntrls_ips=(${cntrls_ips})"
eval "controller_ext_ips=(${controller_ext_ips})"
eval "kube_port=(${kube_port})"
eval "kube_cluster_name=(${kube_cluster_name})"


#Create k8s configs
rm -rf configs/
mkdir configs
cd configs

for instance in ${wrkrs_names[@]}; do
  kubectl config set-cluster ${kube_cluster_name} \
    --certificate-authority=../certs/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:443 \
    --kubeconfig=${instance}.kubeconfig
kubectl config set-credentials system:node:${instance} \
    --client-certificate=../certs/${instance}.pem \
    --client-key=../certs/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig
kubectl config set-context default \
    --cluster=${kube_cluster_name} \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig
kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done


kubectl config set-cluster ${kube_cluster_name} \
  --certificate-authority=../certs/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:443 \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config set-credentials system:kube-proxy \
  --client-certificate=../certs/kube-proxy.pem \
  --client-key=../certs/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config set-context default \
  --cluster=${kube_cluster_name} \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


kubectl config set-cluster ${kube_cluster_name} \
  --certificate-authority=../certs/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:${kube_port} \
  --kubeconfig=kube-controller-manager.kubeconfig
kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=../certs/kube-controller-manager.pem \
  --client-key=../certs/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig
kubectl config set-context default \
  --cluster=${kube_cluster_name} \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig
kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig



kubectl config set-cluster ${kube_cluster_name} \
  --certificate-authority=../certs/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:${kube_port} \
  --kubeconfig=kube-scheduler.kubeconfig
kubectl config set-credentials system:kube-scheduler \
  --client-certificate=../certs/kube-scheduler.pem \
  --client-key=../certs/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig
kubectl config set-context default \
  --cluster=${kube_cluster_name} \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig
kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-cluster ${kube_cluster_name} \
  --certificate-authority=../certs/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:${kube_port} \
  --kubeconfig=admin.kubeconfig
kubectl config set-credentials admin \
  --client-certificate=../certs/admin.pem \
  --client-key=../certs/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig
kubectl config set-context default \
  --cluster=${kube_cluster_name} \
  --user=admin \
  --kubeconfig=admin.kubeconfig
kubectl config use-context default --kubeconfig=admin.kubeconfig



##encryption
cd ..
rm -rf encryption
mkdir encryption
cd encryption

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF