### Create a dns host records on each node in /etc/hosts file
#### Note: Check the IP Address and hostname in your setup given

192.168.2.51 kubemaster01
192.168.2.52 kubemaster02
192.168.2.50 kubelb
192.168.2.61 kubenode01
192.168.2.62 kubenode02


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
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6WZEGpP6HrjeUGyGB9IFl5mO0TAcHloWinn/0aqlGllgbUTMSVoTWCFdJsWvpelof20W2fVyHxcDNqE6xVxYqEqt8gL4I5mD9lBhxmlkfwDooJsEy9D5uGClugPeLqUBJLCi9+LDb1wTBUtyaOLvvLfC9MATziqND4va3bsQpH80Q7+DL2yONyoTW5SikjGJPkbpYBwID+q6F3neIo9F5c39mMXOXPwRMKEjnDYHyQQqJzcgvST8M9CDJdkMYYdhmbjQyG+bBwhzm+IzTJtafdX5tTmp83ES6zktIsGu4cX8RA0XMgqWwVlLAJI1oykSlnXpasAy51mgINDDBmzwN dinesh@kubemaster01
EOF

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


# Provisioning a CA and Generating TLS Certificates

In this lab you will provision a [PKI Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) using the popular openssl tool, then use it to bootstrap a Certificate Authority, and generate TLS certificates for the following components: etcd, kube-apiserver, kube-controller-manager, kube-scheduler, kubelet, and kube-proxy.

# Where to do these?

You can do these on any machine with `openssl` on it. But you should be able to copy the generated files to the provisioned VMs. Or just do these from one of the master nodes.

In our case we do it on the master-1 node, as we have set it up to be the administrative client.


## Certificate Authority

In this section you will provision a Certificate Authority that can be used to generate additional TLS certificates.

Create a CA certificate, then generate a Certificate Signing Request and use it to create a private key:


```
# Create private key for CA
openssl genrsa -out ca.key 2048

# Comment line starting with RANDFILE in /etc/ssl/openssl.cnf definition to avoid permission issues
sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf

# Create CSR using the private key
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr

# Self sign the csr using its own private key
openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000
```
Results:

```
ca.crt
ca.key
```

Reference : https://kubernetes.io/docs/concepts/cluster-administration/certificates/#openssl

The ca.crt is the Kubernetes Certificate Authority certificate and ca.key is the Kubernetes Certificate Authority private key.
You will use the ca.crt file in many places, so it will be copied to many places.
The ca.key is used by the CA for signing certificates. And it should be securely stored. In this case our master node(s) is our CA server as well, so we will store it on master node(s). There is not need to copy this file to elsewhere.

## Client and Server Certificates

In this section you will generate client and server certificates for each Kubernetes component and a client certificate for the Kubernetes `admin` user.

### The Admin Client Certificate

Generate the `admin` client certificate and private key:

```
# Generate private key for admin user
openssl genrsa -out admin.key 2048

# Generate CSR for admin user. Note the OU.
openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr

# Sign certificate for admin user using CA servers private key
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out admin.crt -days 1000
```

Note that the admin user is part of the **system:masters** group. This is how we are able to perform any administrative operations on Kubernetes cluster using kubectl utility.

Results:

```
admin.key
admin.crt
```

The admin.crt and admin.key file gives you administrative access. We will configure these to be used with the kubectl tool to perform administrative functions on kubernetes.

### Worker Node Certificate (kubelet client certs)

Kubernetes uses a [special-purpose authorization mode](https://kubernetes.io/docs/admin/authorization/node/) called Node Authorizer, that specifically authorizes API requests made by [Kubelets](https://kubernetes.io/docs/concepts/overview/components/#kubelet). In order to be authorized by the Node Authorizer, Kubelets must use a credential that identifies them as being in the `system:nodes` group, with a username of `system:node:<nodeName>`. In this section you will create a certificate for each Kubernetes worker node that meets the Node Authorizer requirements.

```
{

declare -A nodearray

nodearray["kubenode01"]="192.168.2.61"
nodearray["kubenode02"]="192.168.2.62"

for i in ${!nodearray[@]}; do

echo working on $i with ip ${nodearray[$i]}

cat > openssl-${i}.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${i}
IP.1 = ${nodearray[$i]}
EOF

openssl genrsa -out ${i}.key 2048
openssl req -new -key ${i}.key -subj "/CN=system:node:${i}/O=system:nodes" -out ${i}.csr -config openssl-${i}.cnf
openssl x509 -req -in ${i}.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out ${i}.crt -extensions v3_req -extfile openssl-${i}.cnf -days 1000

done
}
```

### The Controller Manager Client Certificate

Generate the `kube-controller-manager` client certificate and private key:

```
openssl genrsa -out kube-controller-manager.key 2048
openssl req -new -key kube-controller-manager.key -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr
openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-controller-manager.crt -days 1000
```

Results:

```
kube-controller-manager.key
kube-controller-manager.crt
```


### The Kube Proxy Client Certificate

Generate the `kube-proxy` client certificate and private key:


```
openssl genrsa -out kube-proxy.key 2048
openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy" -out kube-proxy.csr
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-proxy.crt -days 1000
```

Results:

```
kube-proxy.key
kube-proxy.crt
```

### The Scheduler Client Certificate

Generate the `kube-scheduler` client certificate and private key:



```
openssl genrsa -out kube-scheduler.key 2048
openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-scheduler.crt -days 1000
```

Results:

```
kube-scheduler.key
kube-scheduler.crt
```

### The Kubernetes API Server Certificate

The kube-apiserver certificate requires all names that various components may reach it to be part of the alternate names. These include the different DNS names, and IP addresses such as the master servers IP address, the load balancers IP address, the kube-api service IP address etc.

The `openssl` command cannot take alternate names as command line parameter. So we must create a `conf` file for it:

```
cat > openssl.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 192.168.2.51
IP.3 = 192.168.2.52
IP.4 = 192.168.2.50
IP.5 = 127.0.0.1
EOF
```

Generates certs for kube-apiserver

```
openssl genrsa -out kube-apiserver.key 2048
openssl req -new -key kube-apiserver.key -subj "/CN=kube-apiserver" -out kube-apiserver.csr -config openssl.cnf
openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000
```

Results:

```
kube-apiserver.crt
kube-apiserver.key
```

### The ETCD Server Certificate

Similarly ETCD server certificate must have addresses of all the servers part of the ETCD cluster

The `openssl` command cannot take alternate names as command line parameter. So we must create a `conf` file for it:

```
cat > openssl-etcd.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = 192.168.2.51
IP.2 = 192.168.2.52
IP.3 = 127.0.0.1
EOF
```

Generates certs for ETCD

```
openssl genrsa -out etcd-server.key 2048
openssl req -new -key etcd-server.key -subj "/CN=etcd-server" -out etcd-server.csr -config openssl-etcd.cnf
openssl x509 -req -in etcd-server.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd-server.crt -extensions v3_req -extfile openssl-etcd.cnf -days 1000
```

Results:

```
etcd-server.key
etcd-server.crt
```

## The Service Account Key Pair

The Kubernetes Controller Manager leverages a key pair to generate and sign service account tokens as describe in the [managing service accounts](https://kubernetes.io/docs/admin/service-accounts-admin/) documentation.

Generate the `service-account` certificate and private key:

```
openssl genrsa -out service-account.key 2048
openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr
openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out service-account.crt -days 1000
```

Results:

```
service-account.key
service-account.crt
```


## Distribute the Certificates

Copy required files on the controller plane masters

```
declare -A masterarray

masterarray["kubemaster01"]="192.168.2.61"
masterarray["kubemaster02"]="192.168.2.62"

for masternode in ${!masterarray[@]}; do
  scp ca.crt ca.key kube-apiserver.key kube-apiserver.crt \
  service-account.key service-account.crt \
  etcd-server.key etcd-server.crt \ 
  ${masternode}:~/
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
