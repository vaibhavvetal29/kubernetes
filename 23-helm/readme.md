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

## Check the folder structure of the mychart created

> Chart.yaml  # A YAML file containing information about the chart.  
> LICENSE     # OPTIONAL :- A plain text file containing license of the chart.
> README      # OPTIONAL :- A human-readable README file.  
> values.yaml # the default configuration values for this chart.  
> charts/     # A directory containing any charts upon which this chart depends.  
> templates/  # A directory of templates that, when combined with values will generate valid kubernetes files.  



## Let's create chart from scratch
`helm create customchart`
`rm -rf customchart/charts/* customchart/templates/*`

## let's create resources in /templates
create configmap.yaml

```sh
kubectl create configmap customchart-configmap --from-literal=myname="dinesh patil" --dry-run=client -o yaml >customchart/templates/configmap.yaml
```

## Let's Install the chart

helm install demo-configmap ./customchart

## let's remove chart
helm uninstall demo-configmap


## Let'd use templates
change the name as below
```yaml
apiVersion: v1
data:
  myname: dinesh patil
kind: ConfigMap
metadata:
  name: {{ .Release.Name}}-configmap
```

### Check Predefined Values at [link](https://helm.sh/docs/topics/charts/)

## Let's defined few values
> 1) add below code in values.yaml
> 2) update value in the configmap as below
```yaml
apiVersion: v1
data:
  myname: dinesh patil
  function: {{ .Values.function}}  ## Check this line
kind: ConfigMap
metadata:
  name: {{ .Release.Name}}-configmap
```

### let's test release
`helm install --debug --dry-run debugrun ./customchart`

### Let's install the chart
```bash
helm install debugrun ./customchart

# Let's get details related to the already installed helm chart
helm get manifest debugrun
```

## Set values from command at runtime
helm install --debug --dry-run debugrun ./customchart --set function=sales


## Templates function
add more values in values.yaml

```yaml
function: Devops
dept: IT
infra:
   location: mumbai
   floor: 2,3,4
```

## add below in configmap
```yaml
apiVersion: v1
data:
  myname: dinesh patil
  function: {{ .Values.function}}
kind: ConfigMap
metadata:
  name: {{ .Release.Name}}-configmap
  location: {{ upper .Values.infra.location }} # upper will upper the case
  floor: {{quote .Values.infra.floor }} # quote will add values with quote
```
## checkout function to used at
> [gotemplate](https://godoc.org/text/template)
> [spring templates](http://masterminds.github.io/sprig/)

## Template pipeline and default Values
### See below values 
```yaml
location: {{ .Values.infra.location | upper | quote }} # upper will upper the case
date: {{ now | date "2006-01-02" | quote " }}
``` 
### Note: date formatting in the go language is different [Refer](https://golang.org/pkg/time/)


## What if someone doesn't provide value for something

```yaml
company: {{ .Values.company | default "NTMS" | upper | quote }} # upper will upper the case
```

## Flow Control
```go
{{ if PIPELINE}}
  # Do something
{{ else if OTHER PIPELINE}}
  # Do something else
{{ else }}
  # Default 
{{ end }}
```

### **pipeline will be consider as false when**

> a Boolean false
> a numeric zero
> an empty string
> a nil (empty or null)
> an empty collection (map, slice, tuple, dict, array)

## add below in config.yaml to test if flow control
 ```go
 {{ if eq .Values.infra.location "mumbai"}}sub-location: powai {{ end }}
 ```

 ## change the value of the location and test
 

 ## Now check other way around
 ```go
 {{ if eq .Values.infra.location "mumbai"}}
 sub-location: powai 
 {{ end }}
 ```

 ### Did you notice any issue ?

 #### Yes that's blank lines in yaml files

##### add - at beginning to remove the new line
{{- if eq .Values.infra.location "mumbai"}}

#### Try to achieve the same using - before last bracket 
#### Check what happened

## Modifying scope with 'with'
```go
{{ with PIPELINE}}
  ## Restricted scope
{{ end }}
```
### Let's add some more data in the values.yaml
```yaml
tags:
  rack: base1
  storagevendor: netapp
```
### Let's add some more data in the configmap.yaml
```yaml
{{- with .Values.tags}}
  RackID: {{ .rack | quote }}
  storagevendor: {{ .storagevendor | quote}}
  {{- end}}
```
#### NOTE: You will not have access to builtin object 


## Using Range (Looping)
{{- range .Values.collection}}
  - {{. | title | quote}}
{{- end}}

```yaml
## In values.yaml
Language:
   - Python
   - Ruby
   - Java
   - Powershell

## In configmap
  Language: |
    {{- range .Values.Language }}
    - {{ . | quote}}
    {{- end}}
```

## Variables

$name := .Release.Name

```yaml
# In template configmap
{{- $relname := .Release.Name -}}
Release: {{$relname}}
```

## Now let's use variable in range

```yaml
  Language: |-
    {{- range $index, $lang := .Values.Language }}
    - {{ $index }}: {{ $lang }}
    {{- end}}
```

## Global Variable $

```yaml
metadata:
  labels:
    helm.sh/chart : "{{ $.Chart.Name }}-{{ $.Chart.Version }}"
```

## Include content from the same file (Reusability)
#### named templates
```yaml
# remove labels from configmap.yaml. add below lines at start of the yaml file
{{- define "customchart.systemlables" }}
  labels:
     function: IT
     app: frontend
{{- end }}

## Now let's use in chart
{{- template "customchart.systemlabels"}}
```

### Template using otehr file
####  create new file in templates folder _helpers.tpl
#### Add below content in the same
```yaml
{{- define "customchart.systemlables" }}
  labels:
     function: IT
     app: frontend
{{- end }}
#### Try to run dry run

# Add few more things in the _helpers.tpl
{{- define "customchart.systemlables" }}
  labels:
     function: IT
     app: frontend
     releasename: "{{ $.Release.Name }}"
{{- end }}

## Try Dry run now
# What do you observe ? That's scope issue

{{- define "customchart.systemlables" .}} # added "." to add current scope (local)
{{- define "customchart.systemlables" $}} # added "$" for global scope


## Include keyword (In case you have to have expected alignment)
{{- define "customchart.version" -}}
app_name: {{ .Chart.Name }}
app_version: "{{ .Chart.Version }}"
{{- end -}}

## Try to use template and observe change

## Now how can we achieve the expected results

## Add one more in the _helper
{{- define "customchart.appinfo" }}
app_name: "{{ .Chart.Name }}"
app_version: "{{ .Chart.Version }}"
{{- end }}

# Now add below in configmap
  labels: 
  {{- include "customchart.appinfo" . | indent 3 }}

```

## Creating notes 
### Add new file NOTES in templates
```Notes
Your application is install!! enjoy
```


## Subcharts
### Create a subchart in the parent chart

#### try to dry run

Add values for the mysubchart in parent



## Chart repository
HTTP server hosting index.yaml file along with chrat packages [referindexfile](https://helm.sh/docs/topics/chart_repository/)


let's create repo in the github

create new repo

add required permission with token
user> developer settings > PAT

echo "# helmrepo" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/dineshazpatil/helmrepo.git
git push -u origin main


create test chart

`helm create gitrepochart`

create package out of your chart
`helm package /home/dinesh/gitrepochart`

build index
`helm repo index`

git add .
git commit -m chart added
git push -u origin master


get raw repo link
https://raw.githubusercontent.com/dineshazpatil/helmrepo/main/

helm repo list

helm repo add --username dineshazpatil@outlook.com --password f7d9ec6dcd93215f99502eff4de9d4bdd0f62ed5 myhelmrepo https://raw.githubusercontent.com/dineshazpatil/helmrepo/main/


addd new chart
helm repo update

