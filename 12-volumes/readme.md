## Volumes
To use a volume, a Pod specifies what volumes to provide for the Pod (the .spec.volumes field) and where to mount those into Containers (the .spec.containers[*].volumeMounts field).


## Checkout various volumes supported https://kubernetes.io/docs/concepts/storage/volumes/

## Persistent Volumes And Persistent Volume Claims
The volume type is tightly coupled to the pod. The definition must specify which kind of volume the pod shall use. This may be just fine for small to medium environments. However, as the scale grows, it becomes more challenging to handle which pods are using NFS, which need the cloud disk and which utilize iSCSI. For that reason, Kubernetes offers Persistent Volumes and Persistent Volume claims

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

When you use a Persistent Volume Claim, you only care about the requirements of your application. For example, how much space it needs and the access type. Access types define whether or not multiple nodes can access the volume. So, we have:

ReadWriteOnce where only one node is allowed access to the volume.
ReadOnlyMany where one is allowed full access and other nodes are allowed read-only permissions
ReadWriteMany for volumes that can be shared among many nodes and all of them have full access to it.