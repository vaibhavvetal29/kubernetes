# Bootstrapping the etcd Cluster

Kubernetes components are stateless and store cluster state in [etcd](https://github.com/etcd-io/etcd). In this lab you will bootstrap a two node etcd cluster and configure it for high availability and secure remote access.

Check [etcdversionissue](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#known-issue-etcd-client-balancer-with-secure-endpoints).


## Prerequisites

The commands in this lab must be run on each controller instance: `kubemaster01`, `kubemaster02`. Login to each controller instance using the `ssh` command. Example:


## Bootstrapping an etcd Cluster Member

### download binaries on both master nodes

Download the official etcd release binaries from the [etcd](https://github.com/etcd-io/etcd) GitHub project:

> keep open console to both the master server 

ETCD_VERSION=v3.4.10

```
wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz"
```
Extract and install the `etcd` server and the `etcdctl` command line utility:

```
tar -xvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz
sudo mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin/
```


### configure and start the etcd service on both control nodes
```
{
sudo mkdir -p /etc/etcd /var/lib/etcd 
sudo cp ca.crt etcd-server.key etcd-server.crt /etc/etcd/
}
```

> check the files on both server in /etc/etcd


Create the `etcd.service` systemd unit file:

#### on kubemaster01 
ETCD_NAME=$(hostname -s)
INTERNAL_IP=192.168.2.51
ETCDSERVER01_INTERNAL_IP=192.168.2.51
ETCDSERVER02_INTERNAL_IP=192.168.2.52

#### on kubemaster02
ETCD_NAME=$(hostname -s)
INTERNAL_IP=192.168.2.52
ETCDSERVER01_INTERNAL_IP=192.168.2.51
ETCDSERVER02_INTERNAL_IP=192.168.2.52

#### on bothe the nodes
ETCDSERVER01=kubemaster01
ETCDSERVER02=kubemaster02

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/etcd-server.crt \\
  --key-file=/etc/etcd/etcd-server.key \\
  --peer-cert-file=/etc/etcd/etcd-server.crt \\
  --peer-key-file=/etc/etcd/etcd-server.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${ETCDSERVER01}=https://${ETCDSERVER01_INTERNAL_IP}:2380,${ETCDSERVER02}=https://${ETCDSERVER02_INTERNAL_IP}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
### Start the etcd Server

```
{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
}
```


## verification

sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key