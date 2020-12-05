## Installation
create namespace

3) Using helm
    helm install prometheus stable/prometheus-operator
## 

latest beta  insatllation
https://github.com/prometheus-community/helm-charts

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

kubectl --namespace monitor get pods -o wide

## Access Grafana
kubectl port-forward --address=10.0.1.6 deployment/prometheus-grafana 3000 -n monitor

default user: admin
password: prom-operator

## Access Prometheus
kubectl port-forward --address=10.0.1.6 pod/prometheus-prometheus-prometheus-oper-prometheus-0 9090 -n monitor