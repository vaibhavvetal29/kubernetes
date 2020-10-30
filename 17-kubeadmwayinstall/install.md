cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


## Add entries to the hosts file
192.168.2.71 kubeadmmaster01
192.168.2.72 kubeadmmaster02
192.168.2.73 kubeadmnode01
192.168.2.74 kubeadmnode02

## Install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo usermod -aG docker dinesh

## Install kubelet kubeadm kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet


## Initializing your control-plane node

1. (Recommended) If you have plans to upgrade this single control-plane `kubeadm` cluster
to high availability you should specify the `--control-plane-endpoint` to set the shared endpoint
for all control-plane nodes. Such an endpoint can be either a DNS name or an IP address of a load-balancer.
2. Choose a Pod network add-on, and verify whether it requires any arguments to
be passed to `kubeadm init`. Depending on which
third-party provider you choose, you might need to set the `--pod-network-cidr` to
a provider-specific value. See [Installing a Pod network add-on](#pod-network).
3. (Optional) Since version 1.14, `kubeadm` tries to detect the container runtime on Linux
by using a list of well known domain socket paths. To use different container runtime or
if there are more than one installed on the provisioned node, specify the `--cri-socket`
argument to `kubeadm init`. See [Installing runtime](/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime).
4. (Optional) Unless otherwise specified, `kubeadm` uses the network interface associated
with the default gateway to set the advertise address for this particular control-plane node's API server.
To use a different network interface, specify the `--apiserver-advertise-address=<ip-address>` argument
to `kubeadm init`. To deploy an IPv6 Kubernetes cluster using IPv6 addressing, you
must specify an IPv6 address, for example `--apiserver-advertise-address=fd00::101`
5. (Optional) Run `kubeadm config images pull` prior to `kubeadm init` to verify
connectivity to the gcr.io container image registry.

`kubeadm init --control-plane-endpoint 192.168.2.50`



mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


## Run below output on second control plane
```sh
kubeadm join 192.168.2.50:6444 --token cj1q4q.9ockldvyrajh1koc \
    --discovery-token-ca-cert-hash sha256:9fe61ca194b1e2da49d8daf2967b7c2d35454a9c8c6ab35bed660130fc431a36 \
    --control-plane --certificate-key de0d7ddc13d19805a0e4b0973b2bd163270cd671865979d6a94c645e2529d7ad


kubeadm join 192.168.2.50:6444 --token cj1q4q.9ockldvyrajh1koc \
    --discovery-token-ca-cert-hash sha256:9fe61ca194b1e2da49d8daf2967b7c2d35454a9c8c6ab35bed660130fc431a
```

```sh
for node in 192.168.2.74 192.168.2.73 192.168.2.72 192.168.2.71; do 
    echo "working on" $node
    ssh -t $node sudo shutdown
done
```
