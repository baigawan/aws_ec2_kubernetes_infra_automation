eval "wrkrs_names=(${wrkrs_names_ar})"
eval "worker_ips=(${worker_ips})"
eval "worker_ext_ips=(${worker_ext_ips})"
eval "wrkrs_hostname=(${wrkrs_hostname})"

eval "cntrls_names=(${cntrls_names_ar})"
eval "cntrls_ips=(${cntrls_ips})"
eval "controller_ext_ips=(${controller_ext_ips})"

eval "api_server_ip=(${api_server_ip})"


rm -rf certs/
mkdir certs
cd certs


cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF
cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "UnitedStates",
      "O": "Kubernetes",
      "OU": "DevOps",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "UnitedStates",
      "O": "system:masters",
      "OU": "Kubernetes infra",
      "ST": "Oregon"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

for i in $(seq 0 $wrkrs_count); do
  instance=${wrkrs_names[$i]}
  instance_hostname=${wrkrs_hostname[$i]}
 
  cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance_hostname}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "UnitedStates",
      "O": "system:nodes",
      "OU": "Kubernetes infra",
      "ST": "Oregon"
    }
  ]
}
EOF

external_ip=${worker_ext_ips[$i]}
internal_ip=${worker_ips[$i]}

cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -hostname=${instance_hostname},${external_ip},${internal_ip} \
    -profile=kubernetes \
    ${instance}-csr.json | cfssljson -bare ${instance}

done


cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "UnitedStates",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes infra",
      "ST": "Oregon"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager


cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "UnitedStates",
      "O": "system:node-proxier",
      "OU": "Kubernetes infra",
      "ST": "Oregon"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "UnitedStates",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes infra",
      "ST": "Oregon"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler


KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "UnitedStates",
      "O": "Kubernetes",
      "OU": "Kubernetes infra",
      "ST": "Oregon"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${api_server_ip},${cntrl_ip_str},${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "UnitedStates",
      "O": "Kubernetes",
      "OU": "Kubernetes infra",
      "ST": "Oregon"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

