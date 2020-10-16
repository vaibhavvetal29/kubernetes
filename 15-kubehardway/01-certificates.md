Refer https://github.com/kelseyhightower/kubernetes-the-hard-way


### Install certificate provider

sudo apt install golang-cfssl

#### Check Installation
`cfssl version`


### Install kubectl 

refer https://kubernetes.io/docs/tasks/tools/install-kubectl/

KUBECTLVERSION="v1.18.6"

##### Download file

`curl -LO "https://storage.googleapis.com/kubernetes-release/release/$KUBECTLVERSION/bin/linux/amd64/kubectl"`

##### Make Kubectl binary executable

`chmod +x ./kubectl`

##### MOve the binary to your PATH

`sudo mv ./kubectl /usr/local/bin/kubectl`

##### Test kubectl version

`kubectl version --client`



### Create a dns host records on each node in /etc/hosts file
#### Note: Check the IP Address and hostname in your setup given

192.168.2.51 kubemaster01
192.168.2.52 kubemaster02
192.168.2.50 kubelb
192.168.2.61 kubenode01
192.168.2.62 kubenode02

Note : Check specifically the Ip's before adding records.

### Create direct login to other VM's by using sshkey

ssh-keygen 

#### from home directory copy id_rsa.pub to each other node

cat .ssh/id_rsa.pub

##### It looks like below
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCM0Evq2Zw+2N7sWXrm/O8vZPevCshyWtyfxSFjPbTnyDOOBaA7pCOiGGqrbTPjYzE2MUjmglTOAxP5I9EyhS8tO8Lmjrt4qDvEHJJLTXrwlZz6H3DQeFQptk+Kz7FFyaJHnCeV+o0rtxvmszTG0KJzcfI9oPLsiecATPSHNlZJ3WyLHrmcjVZkUT8eQMolvHaWiBi4fTsZXHMTQbHQC+ic9Lq51DNYxf3etsuODMSURIqgr9xf1WURLQNMX559cOfFJ8P+MvOHK4+Cjx7mCEr+W8SnmO8i4CrDLtueP1YEF1vxps6LHaov+RfwbjC/YXh1zs2ewXG+O2y6EiFocZh dinesh@kubemaster01

###### Note By default .ssh folder does not exist
Create folder first 
`mkdir .ssh`
cat >>~/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCM0Evq2Zw+2N7sWXrm/O8vZPevCshyWtyfxSFjPbTnyDOOBaA7pCOiGGqrbTPjYzE2MUjmglTOAxP5I9EyhS8tO8Lmjrt4qDvEHJJLTXrwlZz6H3DQeFQptk+Kz7FFyaJHnCeV+o0rtxvmszTG0KJzcfI9oPLsiecATPSHNlZJ3WyLHrmcjVZkUT8eQMolvHaWiBi4fTsZXHMTQbHQC+ic9Lq51DNYxf3etsuODMSURIqgr9xf1WURLQNMX559cOfFJ8P+MvOHK4+Cjx7mCEr+W8SnmO8i4CrDLtueP1YEF1vxps6LHaov+RfwbjC/YXh1zs2ewXG+O2y6EiFocZh dinesh@kubemaster01
EOF


### Let's create a workdir to create all our certification and configuration
mkdir workdir
cd workdir


### Provision the certificate authority(CA)

```
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
```
**Check the files created soreted by created time**
ls -ltc
ls -ltc | head -4
ls -ltc | tail -4

### Admin Client cert

Generate the `admin` client certificate and private key:

Check below links for various groups for cert
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#:~:text=system%3Amasters%20group,cluster%20and%20in%20all%20namespaces. 

```
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
```

### Worker Node Certificate (kubelet client certs)

Kubernetes uses a [special-purpose authorization mode](https://kubernetes.io/docs/admin/authorization/node/) called Node Authorizer, that specifically authorizes API requests made by [Kubelets](https://kubernetes.io/docs/concepts/overview/components/#kubelet). In order to be authorized by the Node Authorizer, Kubelets must use a credential that identifies them as being in the `system:nodes` group, with a username of `system:node:<nodeName>`. In this section you will create a certificate for each Kubernetes worker node that meets the Node Authorizer requirements.

```
{

declare -A nodearray

nodearray["kubenode01"]="192.168.2.61"
nodearray["kubenode02"]="192.168.2.62"

for i in ${!nodearray[@]}; do

echo working on $i with ip ${nodearray[$i]}

cat > ${i}-csr.json << EOF
{
  "CN": "system:node:${i}",
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
  -hostname=${nodearray[$i]},${i} \
  -profile=kubernetes \
  ${i}-csr.json | cfssljson -bare ${i}

done
}
```


### kube Controller Manager
Generate the `kube-controller-manager` client certificate and private key:
```
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
```

### Kube Proxy Client cert
Generate the `kube-proxy` client certificate and private key:
```
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
```
### kube-scheduler client certificate
Generate the `kube-scheduler` client certificate and private key:
```
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
```

### kubeapi server

The `kubernetes-the-hard-way` static IP address will be included in the list of subject alternative names for the Kubernetes API Server certificate. This will ensure the certificate can be validated by remote clients.
```
KUBERNETES_MASTER_IP_ADDRESS=192.168.2.50,192.168.2.51,192.168.2.52
KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local,localhost

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
  -hostname=10.32.0.1,127.0.0.1,${KUBERNETES_MASTER_IP_ADDRESS},${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}
```

### Service Account

The Kubernetes Controller Manager leverages a key pair to generate and sign service account tokens as described in the [managing service accounts](https://kubernetes.io/docs/admin/service-accounts-admin/) documentation.

```
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

```

ETCD Server Certificate

```
KUBERNETES_ETCD_IP_ADDRESS=192.168.2.51,192.168.2.52

{

cat > etcd-csr.json << EOF
{
  "CN": "etcd-server",
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
  -hostname=${KUBERNETES_ETCD_IP_ADDRESS} \
  -profile=kubernetes \
  etcd-csr.json | cfssljson -bare etcd-server

}
```


### Distribute the Certificates

Copy required files on the controller plane masters

```
declare -A masterarray

masterarray["kubemaster01"]="192.168.2.61"
masterarray["kubemaster02"]="192.168.2.62"

for masternode in ${!masterarray[@]}; do
  scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem etcd-server.pem etcd-server-key.pem ${masternode}:~/
done

```

Copy required files on the nodes

```
declare -A nodearray

nodearray["kubenode01"]="192.168.2.61"
nodearray["kubenode02"]="192.168.2.62"

for node in ${!nodearray[@]}; do
  scp ca.pem ${node}.pem ${node}-key.pem ${node}:~/
done

```

