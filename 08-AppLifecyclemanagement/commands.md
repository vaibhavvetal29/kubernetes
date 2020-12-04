create some deployment

now check the rollout status of deployment
kubectl rollout status deployment/myrelease-deployment
kubectl rollout history deployment/myrelease-deployment

Deployment Strategy
making all down and then make all new up
Recreate

making one by one old version down and new up
Rolling Update


kubectl set image deployment/myrelease-rollingupdate-dp nginx=nginx:alpine

kubectl rollout undo deployment/myrelease-deployment



kubectl rollout pause deployment/myrelease-deployment
kubectl set image deployment/myrelease-deployment nginx=nginx:1.16.1
kubectl rollout resume deployment/myrelease-deployment

check rollout status
echo $?


Failed Deployment 
Your Deployment may get stuck trying to deploy its newest ReplicaSet without ever completing. This can occur due to some of the following factors:

Insufficient quota
Readiness probe failures
Image pull errors
Insufficient permissions
Limit ranges
Application runtime misconfiguration


kubectl patch deployment/myrelease-deployment -p '{"spec":{"progressDeadlineSeconds":600}}'

Once the deadline has been exceeded, the Deployment controller adds a DeploymentCondition with the following attributes to the Deployment's .status.conditions:

Type=Progressing
Status=False
Reason=ProgressDeadlineExceeded


### Help me to check the default command in case of below images
    1) nginx
    2) ubuntu

`docker run ubuntu sleep 5`

CMD sleep 5
CMD ["command","args"]


FROM Ubuntu

ENTRYPOINT ["sleep"]


FROM Ubuntu

ENTRYPOINT ["sleep"]

CMD ["5"]


## Add below paramater in the Ubuntu image and then create a pod 
command: ["sleep"]
args: ["10","-q",""]

### Environement Variables
env:
 - name: myenv
   value: test
 





### Task check how to use valueFrom:
    1) configMapRef
    2) secretkeyRef

### Config Maps: /// Trubleshoot what is missing in below configmap command
`kubectl create configmap --from-literal=myuser=dinesh`
`kubectl create configmap --from-literal=myuser=dinesh --from-literal=mylastname=patil`
```yaml
env:
            - name: usernameref
              valueFrom:
                configMapKeyRef:
                    name: namemaps1
```


#### Task create the same using the declarative approach


Using config maps in Pods
envFrom:
 - configMapRef:
     name: myconfig


### Secrets
`kuebctl create secret mysecret --from-literal=myuser="dinesh"`

echo -n "dinesh" | base64



### Multicontainer Pods

Create POD with multicontaien rin it


 ### [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
 This page provides an overview of init containers: specialized containers that run before app containers in a Pod. Init containers can contain utilities or setup scripts not present in an app image.

#### Init containers are exactly like regular containers, except:
        Init containers always run to completion.
        Each init container must complete successfully before the next one starts.


