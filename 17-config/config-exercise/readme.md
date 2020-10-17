## Add cluster info
kubectl config --kubeconfig=config set-cluster kind-kubecluster21 --server=https://10.10.0.1:6443 --certificate-authority=kube-ca.crt

## Add User info
### By using Basic Auth
kubectl config --kubeconfig=config set-credentials kind-kind --username=dinesh --password="P@ssw0rd"

### Certificate
kubectl config --kubeconfig=config set-credentials kind-kubecluster2 --client-certificate=kubecluster2.crt --client-key=kubecluster2.key

## Removal
sudo kubectl --kubeconfig=config config unset users.kind-kind
sudo kubectl --kubeconfig=config config unset clusters.
sudo kubectl --kubeconfig=config config unset contexts. 


## Adding Contexts
sudo kubectl config --kubeconfig=config set-context kind-kindcon --cluster=kind-kind --user=kind-kind
sudo kubectl config --kubeconfig=config set-context kind-kindcon --cluster=kind-kind --user=kind-kind --namespace=developerns

## View config
kubectl config view ## This will pick up env variable KUBECONFIG or .kube/config
kubectl config --kubeconfig=config  view ## This will pick up local config file or path provided

## information related to current context
kubectl config view --minify

## Switch context
sudo kubectl config use-context kind-kind


