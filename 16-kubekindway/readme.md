https://kind.sigs.k8s.io/docs/user/quick-start/

sudo apt-get update


### Install go language
cd /tmp
wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
sudo tar -xvf go1.11.linux-amd64.tar.gz
sudo chown -R root:root ./go
sudo mv go /usr/local
sudo nano ~/.profile
source ~/.profile 
mkdir $HOME/work
go

### Verification for go langunge
go version

### Install Docker on you system
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker dinesh

### Verfication for docker
cd 
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
chmod +x ./kind

sudo mv ./kind /usr/local/bin/kind

### Create your first cluster
sudo kind create cluster
kubectl config view

KUBECTLVERSION="v1.18.6"
curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTLVERSION}/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl config view

sudo kind create cluster --name kubecluster2
   
