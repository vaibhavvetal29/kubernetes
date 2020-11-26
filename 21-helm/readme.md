## Helm is the package manager for Kubernetes.
#### You can read detailed background information in the [CNCF Helm Project Journey report.](https://www.cncf.io/cncf-helm-project-journey-report/)

#### It provides the ability to provide, share, and use software built for Kubernetes.

#### Package managers are used to simplify the process of installing, upgrading, reverting, and removing a system's applications. These applications are defined in units, called packages, which contain metadata around target software and its dependencies.

#### **Helm**, on the other hand, works with charts. A Helm chart can be thought of as a Kubernetes package. Charts contain the declarative Kubernetes resource files required to deploy an application.


#### Helm relies on repositories to provide widespread access to charts. Chart developers create declarative YAML files, package them into charts, and publish them to chart repositories. 


## Installing Helm [Link](https://helm.sh/docs/intro/install/)

### From Binary Release

#### Every release of Helm provides binary releases for a variety of OSes. These binary versions can be manually downloaded and installed.

> 1) Download your desired version  
> 2) Unpack it 
>    `tar -zxvf helm-v3.0.0-linux-amd64.tar.gz`
> 3) Find the helm binary in the unpacked directory, and move it to its desired destination 
> `mv linux-amd64/helm /usr/local/bin/helm`


### From Script
Helm now has an installer script that will automatically grab the latest version of Helm and install it locally.

> `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3`
> `chmod 700 get_helm.sh`
> `./get_helm.sh`


### Add stable repo

> `helm repo add stable https://charts.helm.sh/stable`
> `helm search repo stable`
> `helm repo update `

### Install stable chart
> `helm install stable/mysql --generate-name`


### Repo
hub.helm.sh

linux cache path $HOME/.cache/helm
windows %TEMP%\helm


## search 
helm search hub

helm search hub mysql


## search specific repo

helm search repo stable

## add specific repo

helm repo add stable https://kubernetes-charts.storage.googleapis.com


## helm repo list

`helm repo list`
`helm search repo stable`
`helm search repo stable/mysql`



## Chart Install

### if you are not able to get any new charts in search list then run below command

`helm repo update`

`helm install stable/mysql `

### check what this parameter do--generate-name

check what is installed
helm ls
helm uninstall mysql




### Helm Components

> **Helm Client**  
>   Helm binary by which we can connect with the helm repo, chart and kubernetes.     
> **Charts**  
>   Application package > All application files    
> **Repositories**  
>   Stores and Manages the Charts    
> **Release**  
>   Chart instance loaded into Kubernetes each release with version




## Create new Helm Chart

helm create mychart

basic structure will be created.

## check deployment file