## DaemonSet

A DaemonSet ensures that all (or some) Nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them. As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created.

Some typical uses of a DaemonSet are:

running a cluster storage daemon on every node
running a logs collection daemon on every node
running a node monitoring daemon on every node



check what is 
If you specify a .spec.template.spec.nodeSelector, then the DaemonSet controller will create Pods on nodes which match that node selector. Likewise if you specify a .spec.template.spec.affinity