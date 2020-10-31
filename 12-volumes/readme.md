## Volumes
To use a volume, a Pod specifies what volumes to provide for the Pod (the .spec.volumes field) and where to mount those into Containers (the .spec.containers[*].volumeMounts field).


## Checkout various volumes supported https://kubernetes.io/docs/concepts/storage/volumes/

## Persistent Volumes And Persistent Volume Claims
The volume type is tightly coupled to the pod. The definition must specify which kind of volume the pod shall use. This may be just fine for small to medium environments. However, as the scale grows, it becomes more challenging to handle which pods are using NFS, which need the cloud disk and which utilize iSCSI. For that reason, Kubernetes offers Persistent Volumes and Persistent Volume claims

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

When you use a Persistent Volume Claim, you only care about the requirements of your application. For example, how much space it needs and the access type. Access types define whether or not multiple nodes can access the volume. So, we have:

ReadWriteOnce where only one pod is allowed access to the volume.
ReadOnlyMany where one is allowed full access and other nodes are allowed read-only permissions
ReadWriteMany for volumes that can be shared among many nodes and all of them have full access to it.

## pvReclaimPolicy
Retain: This reclaim policy indicates that the data stored in the PV is kept in storage even after the PV has been released. The administrator will need to delete the data in storage manually. In this policy, the PV is marked as Released instead of Available. Thus, a Released PV may not necessarily be empty.

Recycle: Using this reclaim policy means that once the PV is released, the data on the volume is deleted using a basic rm -rf command. This marks the PV as Available and hence ready to be claimed again. Using dynamic provisioning is a better alternative to using this reclaim policy. We will discuss the dynamic provisioning in the next section.

Delete: Using this reclaim policy means that once the PV is released, both the PV as well as the data stored in the underlying storage will be deleted.

## PVStatus
Available: This indicates that the PV is available to be claimed.
Bound: This indicates that the PV has been bound to a PVC.
Released: This indicates that the PVC bound to this resource has been deleted; however, it's yet to be reclaimed by some other PVC.
Failed: This indicates that there was a failure during reclamation.

## StorageClass
A StorageClass provides a way for administrators to describe the "classes" of storage they offer. Different classes might map to quality-of-service levels, or to backup policies, or to arbitrary policies determined by the cluster administrators. Kubernetes itself is unopinionated about what classes represent. This concept is sometimes called "profiles" in other storage systems