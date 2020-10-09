### download binaries on both master nodes
wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v3.3.5/etcd-v3.3.5-linux-amd64.tar.gz"
tar -xvf etcd-v3.3.5-linux-amd64.tar.gz
sudo mv etcd-v3.3.5-linux-amd64/etcd* /usr/local/bin/

copy certificates to master02

scp ca.pem kubernetes-key.pem kubernetes.pem kubemaster02:~/workdir
### configure and start the etcd service on both control nodes
sudo mkdir -p /etc/etcd /var/lib/etcd \
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

#### on kubemaster01 
ETCD_NAME=kubemaster01
INTERNAL_IP=192.168.1.51
KUBEMASTER01_INTERNAL_IP=192.168.1.51
KUBEMASTER02_INTERNAL_IP=192.168.1.52

#### on kubemaster02
ETCD_NAME=kubemaster02
INTERNAL_IP=192.168.1.52
KUBEMASTER01_INTERNAL_IP=192.168.1.51
KUBEMASTER02_INTERNAL_IP=192.168.1.52



cat << EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster kubemaster01=https://${KUBEMASTER01_INTERNAL_IP}:2380,kubemaster02=https://${KUBEMASTER02_INTERNAL_IP}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


## verification

sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem