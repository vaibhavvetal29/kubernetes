StatefulSet is the workload API object used to manage stateful applications.

Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods.


StatefulSets are valuable for applications that require one or more of the following.
1) Stable, unique network identifiers.
2) Stable, persistent storage.
3) Ordered, graceful deployment and scaling.
4) Ordered, automated rolling updates.

For a StatefulSet with n replicas, each Pod is assigned a unique integer ordinal between 0 and n – 1. The names of the Pods reflect the integer identity assigned to them. When a StatefulSet is created, all the Pods are created in the order of their integer ordinal.

## Headless Service

which give dns name to reach single pod when we will create headless service

podname.headless-servicename.namespace.svc.cluster-domain.example


mention a clusterIP: none

In deployment:
Add a subdomain in pod as service name
also provide hostname : mysql-pod


statfulset automatically assign to hostname and subdomain 

only thing is we need to assign servicename: headlessservice


volumeclaimtemplate