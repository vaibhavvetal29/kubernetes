### Accessing Private Repository

`kubectl create secret docker-registry regcred \
--docker-server= gen-registry.io \
--docker-username= username\
--docker-password= password\
--docker-email= username@gen.com 


```yaml
apiVersion: v1
kind: Pod 
metadata:
  name: myfirstpod
  labels:
     app: myfirstapp
     function: IT
spec:
  containers:
    - name: mynginxcontainer
      image: nginx
  imagePullSecrets:
  - name: regcred
```