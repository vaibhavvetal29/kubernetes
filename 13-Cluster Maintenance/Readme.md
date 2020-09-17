# Refer 
## https://kubernetes.io/docs/tasks/administer-cluster/cluster-management/



## OS Upgrades

#### Node are down for 5 Mins Pod-Evitction-Timeout=5m

#### Can be set on kube-controller-manager

#### Consider you have below cluster
**Nodename** | **Role**
:-----------:|:-----------:
kubemaster | Master (ControlPlane)
kubenode01 | WorkerNode
kubenode02 | WorkerNode
kubenode03 | WorkerNode

## Maintenance on a Node kubenode01

### Workflow

#### drain the node from the cluster 
    1) This will mark node as noSchedule
    2) This will terminate all the pods on the node.
        a. Pods which have replicaset, will get scheduled to other nodes and if Service is configured then user will not experience outage
        b. Pods which don't have replicaset will need to be scheduled to other node manually, application outage will be there.As well need to redirect all user to the new pod.

##### command
> kubectl drain {nodename}
> kubectl drain kubenode01

#### Conrdoning node
    1) This will just mark node as noSchedule will not cause terminattion of existing running pods



##### kubectl drain kubenode

**commands**
```yaml
kubetl drain kubenode
kubectl drain kubenode --ignore-daemonsets

kubectl uncordon kubenode


kubectl cordon kubenode
``` 



## Upgrades

Kubernetes Release

major.minor(Features).patch(Bugs)

July 2015 v1.0
alpha (first version)
beta (code tested)

none of the components can be greater then kube apiserver version

kubeapi- 1.19 controllers and scheduler can be 1.18 or 1.19 kubelet and kube-proxy can be 1.17,1.18,1.19

Kubernetes support last 3 revision

one minor version at a time

kubeadm upgrade plan

kubeadm upgrade apply


first master and then worker node


kubectl get nodes (version of kubeelet)

apt-get upgrade -y kubelet=1.19

systemctl restart kubelet


kubectl drain node
apt-get upgrade -y kubeadm=1.19
apt-get upgrade -y kubelet=1.19

kubeadm upgrade node config --kubelet-version v1.19

kubectl uncordon node-1

Backup and Restore
Resource Configuration  == > ETCD Cluster  ==> PV

Keep all your resources in Repository

kubectl get all --all-namespaces -o yaml > all-deploy-services.yaml



ETCD Backup

/var/lib/etcd
ETCDCTL_API=3 etcdctl snapshot save snapshot.db
ETCDCTL_API=3 etcdctl snapshot status snapshot.db

stop kubeapiservice
service kube-apiserver stop


reload daemon-re

