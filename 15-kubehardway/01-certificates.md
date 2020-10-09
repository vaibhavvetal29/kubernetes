Refer https://github.com/kelseyhightower/kubernetes-the-hard-way


### Install certificate provider

sudo apt install golang-cfssl

### Create a dns host records on each node in /etc/hosts file

192.168.1.51 kubemaster01
192.168.1.52 kubemaster02
192.168.1.53 lbserver
192.168.1.54 kubenode01
192.168.1.55 kubenode02

Note : Check specifically the Ip's before adding records.

### Create direct login to other VM's by using sshkey

ssh-keygen 

#### from home directory copy id_rsa.pub to each other node

cat .ssh/id_rsa.pub

##### It looks like below
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCheQfgXtXJXD2Rdr69DNrPhOHKB5/AZPmi7yzeknuzk841Uw0HMwn44g6ZH0luvYxfQTiLdOpw1BUamLTFJ5RzlagRwFZOQ0bsQOTzJ9EUY3koEH0UuqEhheMOpi+kzoQUyaycKWuyXlYqsW4pejno75sIYKd0pwO5YtHoH9Cfn98fD8hIDzHhm+BHRb3yYR770RVRV0RViCBcmFWxFxlbqfR6G8y1x0Pgax5hHlMs1rBulKm4nvXtHF1sH6TAp+9LMVFtkmh8sZ/oHy2YTt1y2osfCuBt6jZN4z6TBA9sW6nbrhUxoBRwWVKD7AOesWIl/+ar40AO6D2DafrdqZvH kubeadmin@kubemaster01

###### Note By default .ssh folder does not exist
Create folder first 
`mkdir .ssh`
cat >>~/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCheQfgXtXJXD2Rdr69DNrPhOHKB5/AZPmi7yzeknuzk841Uw0HMwn44g6ZH0luvYxfQTiLdOpw1BUamLTFJ5RzlagRwFZOQ0bsQOTzJ9EUY3koEH0UuqEhheMOpi+kzoQUyaycKWuyXlYqsW4pejno75sIYKd0pwO5YtHoH9Cfn98fD8hIDzHhm+BHRb3yYR770RVRV0RViCBcmFWxFxlbqfR6G8y1x0Pgax5hHlMs1rBulKm4nvXtHF1sH6TAp+9LMVFtkmh8sZ/oHy2YTt1y2osfCuBt6jZN4z6TBA9sW6nbrhUxoBRwWVKD7AOesWIl/+ar40AO6D2DafrdqZvH kubeadmin@kubemaster01
EOF

mkdir workdir
cd workdir


### Provision the certificate authority(CA)

{

cat > ca-config.json << EOF
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

cat > ca-csr.json << EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "Thane",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Maharashtra"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}

### Admin Client cert

Check below links for various groups for cert
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#:~:text=system%3Amasters%20group,cluster%20and%20in%20all%20namespaces. 


{

cat > admin-csr.json << EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "Mumbai",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Maharashtra"
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

}

### Worker Node Certificate (kubelet client certs)
{
cat > kubenode01-csr.json << EOF
{
  "CN": "system:node:kubenode01",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "Mumbai",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Maharashtra"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=192.168.1.54,kubenode01 \
  -profile=kubernetes \
  kubenode01-csr.json | cfssljson -bare kubenode01

cat > kubenode02-csr.json << EOF
{
  "CN": "system:node:kubenode02",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=192.168.1.55,kubenode02 \
  -profile=kubernetes \
  kubenode02-csr.json | cfssljson -bare kubenode02

}


### kube Controller Manager
{

cat > kube-controller-manager-csr.json << EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "Mumbai",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Maharashtra"
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

}

### Kube Proxy Client cert
{

cat > kube-proxy-csr.json << EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "Mumbai",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Maharashtra"
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

}

### kube-scheduler client certificate
{

cat > kube-scheduler-csr.json << EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "Mumbai",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Maharashtra"
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

}


### kubeapi server

{

cat > kubernetes-csr.json << EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "Mumbai",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Maharashtra"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.96.0.1,127.0.0.1,192.168.1.51,192.168.1.52,192.168.1.53,kubemaster01,kubemaster02,lbserver,localhost,kubernetes,kubernetes.default.svc,kubernetes.default.svc.cluster.local,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}

### Service Account

{

cat > service-account-csr.json << EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "Mumbai",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Maharashtra"
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

}



