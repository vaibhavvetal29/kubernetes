### Scheduling
    In Kubernetes, scheduling refers to making sure that Pods are matched to Nodes so that Kubelet can run them.

## Scheduling Overview
    1. Watches for the newly created Pods (no node assigned yet).
    2. Responsible for finding the best Node for that POD.
       (Follows some scheduling principles )

## kube-scheduler
 1. default scheduler for Kubernetes in control plane.
 2. you can also write custom scheduler
 3. Select and optimal node
 4. Nodes that meet the scheduling requirements for a Pod are called feasible nodes.
 5. If none of the nodes are suitable, the pod remains unscheduled until the scheduler is able to place it.
 6. After selecting feasible node, the scheduler then notifies the API server about this decision in a process called binding.

## Node Sleection in kube-scheduler  
### 2 step operations  
    ..* Filtering  
        1. PodFitsResources filter based on Pod's specific resource requests.
    ..* Scoring
        1. Ranks the nodes to choose most suitable


## There are two supported ways to configure the filtering and scoring behavior of the scheduler
    1. Scheduling Policies allow you to configure Predicates for filtering and Priorities for scoring.  

#### Predicates List (refer for more details : https://kubernetes.io/docs/reference/scheduling/policies/) 
    1. PodFitsHostPorts: free ports.
    2. PodFitsHost: Pod specifies a specific Node
    3. PodFitsResources: Checks if the Node has free resources (eg, CPU and Memory) to meet the requirement of the Pod.
    4. PodMatchNodeSelector: Checks if a Pod's Node Selector matches the Node's label(s).
    5. NoVolumeZoneConflict: Evaluate if the Volumes that a Pod requests are available on the Node
    6. NoDiskConflict: Evaluates if a Pod can fit on a Node due to the volumes it requests, and those that are already mounted.
    7. MaxCSIVolumeCount: Decides how many CSI (Container Storage Interface) volumes should be attached, and whether that's over a configured limit.
    8. CheckNodeMemoryPressure: If a Node is reporting memory pressure.
    9. CheckNodePIDPressure: If a Node is reporting that process IDs are scarce
    10.CheckNodeDiskPressure: If a Node is reporting storage pressure 
    11.CheckNodeCondition: Nodes can report that they have a completely full filesystem, that networking isn't available or that kubelet is otherwise not ready to run Pods.
    12. PodToleratesNodeTaints: checks if a Pod's tolerations can tolerate the Node's taints.
    13. CheckVolumeBinding: Evaluates if a Pod can fit due to the volumes it requests. This applies for both bound and unbound PVCs.

#### Priorities The following priorities implement scoring:
  1.  SelectorSpreadPriority: Spreads Pods across hosts, considering Pods that belong to the same Service, StatefulSet or ReplicaSet.
  2. InterPodAffinityPriority: Implements preferred inter pod affininity and antiaffinity.
  3. LeastRequestedPriority: Favors nodes with fewer requested resources. In other words, the more Pods that are placed on a Node, and the more resources those Pods use, the lower the ranking this policy will give.
  4. MostRequestedPriority: Favors nodes with most requested resources. This policy will fit the scheduled Pods onto the smallest number of Nodes needed to run your overall set of workloads.
  5. RequestedToCapacityRatioPriority: Creates a requestedToCapacity based ResourceAllocationPriority using default resource scoring function shape.
  6. BalancedResourceAllocation: Favors nodes with balanced resource usage.
  7. NodePreferAvoidPodsPriority: Prioritizes nodes according to the node annotation scheduler.alpha.kubernetes.io/preferAvoidPods.
  8. NodeAffinityPriority: Prioritizes nodes according to node affinity scheduling preferences indicated in PreferredDuringSchedulingIgnoredDuringExecution. 
  9. TaintTolerationPriority: Prepares the priority list for all the nodes, based on the number of intolerable taints on the node.
  10. ImageLocalityPriority: Favors nodes that already have the container images for that Pod cached locally.
  11. ServiceSpreadingPriority: For a given Service, this policy aims to make sure that the Pods for the Service run on different nodes.
  12. EqualPriority: Gives an equal weight of one to all nodes.
  13. EvenPodsSpreadPriority: Implements preferred pod topology spread constraints.



## Taints and Tolerations
**Node affinity**, is a property of Pods that attracts them to a set of nodes
**Taints** are the opposite -- they allow a node to repel a set of pods.

**Tolerations** are applied to pods, and allow the pods to schedule onto nodes with matching taints.


**Concepts:**

add taints 
kubectl taint nodes node1 key=value:NoSchedule

remove taints
kubectl taint nodes node1 key:NoSchedule-

add tolerations
```yaml
tolerations:
- key: "key"
  operator: "Equal"
  value: "value"
  effect: "NoSchedule"

tolerations:
- key: "key"
  operator: "Exists"
  effect: "NoSchedule" # PreferNoSchedule, NoExecute (Evicted if already running)
```

The default value for operator is Equal.

A toleration "matches" a taint if the keys are the same and the effects are the same, and:

the operator is Exists (in which case no value should be specified), or
the operator is Equal and the values are equal.

**Note:**
There are two special cases:
An empty key with operator Exists matches all keys, values and effects which means this will tolerate everything.
An empty effect matches all effects with key key.
```yaml
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoExecute"
  tolerationSeconds: 3600 **HOW MUCH Time pod will stay bound**
```
Use Cases:
Dedicated Nodes:
Nodes with Special Hardware:


The node controller automatically taints a Node when certain conditions are true. The following taints are built in:

node.kubernetes.io/not-ready: Node is not ready. This corresponds to the NodeCondition Ready being "False".
node.kubernetes.io/unreachable: Node is unreachable from the node controller. This corresponds to the NodeCondition Ready being "Unknown".
node.kubernetes.io/out-of-disk: Node becomes out of disk.
node.kubernetes.io/memory-pressure: Node has memory pressure.
node.kubernetes.io/disk-pressure: Node has disk pressure.
node.kubernetes.io/network-unavailable: Node's network is unavailable.
node.kubernetes.io/unschedulable: Node is unschedulable.
node.cloudprovider.kubernetes.io/uninitialized: When the kubelet is started with "external" cloud provider, this taint is set on a node to mark it as unusable. After a controller from the cloud-controller-manager initializes this node, the kubelet removes this taint.

## Pod Priority and Preemption
Pods can have priority. Priority indicates the importance of a Pod relative to other Pods.
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "This priority class should be used for XYZ service pods only."

#POD Priority
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  priorityClassName: high-priority

```
### Preemption : Select nodes for the Pod can be scheduled on specific node.



## Scheduler Configuration
You can customize the behavior of the kube-scheduler by writing a configuration file and passing its path as a command line argument

You can specify scheduling profiles by running kube-scheduler --config <filename>, using the component config APIs (v1alpha1 or v1alpha2). The v1alpha2 API allows you to configure kube-scheduler to run multiple profiles.
```yaml
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: /etc/srv/kubernetes/kube-scheduler/kubeconfig
```
**Profiles**
A scheduling Profile allows you to configure the different stages of scheduling in the kube-scheduler. Each stage is exposed in an extension point

**Extension points**
```yaml
Scheduling happens in a series of stages that are exposed through the following extension points:
QueueSort: These plugins provide an ordering function that is used to sort pending Pods in the scheduling queue. Exactly one queue sort plugin may be enabled at a time.
PreFilter: These plugins are used to pre-process or check information about a Pod or the cluster before filtering. They can mark a pod as unschedulable.
Filter: These plugins are the equivalent of Predicates in a scheduling Policy and are used to filter out nodes that can not run the Pod. Filters are called in the configured order. A pod is marked as unschedulable if no nodes pass all the filters.
PreScore: This is an informational extension point that can be used for doing pre-scoring work.
Score: These plugins provide a score to each node that has passed the filtering phase. The scheduler will then select the node with the highest weighted scores sum.
Reserve: This is an informational extension point that notifies plugins when resources have been reserved for a given Pod. Plugins also implement an Unreserve call that gets called in the case of failure during or after Reserve.
Permit: These plugins can prevent or delay the binding of a Pod.
PreBind: These plugins perform any work required before a Pod is bound.
Bind: The plugins bind a Pod to a Node. Bind plugins are called in order and once one has done the binding, the remaining plugins are skipped. At least one bind plugin is required.
PostBind: This is an informational extension point that is called after a Pod has been bound.
```

**Scheduling plugins**
_The following plugins, enabled by default, implement one or more of these extension points:_
```yaml
SelectorSpread: Favors spreading across nodes for Pods that belong to Services, ReplicaSets and StatefulSets Extension points: PreScore, Score.
ImageLocality: Favors nodes that already have the container images that the Pod runs. Extension points: Score.
TaintToleration: Implements taints and tolerations. Implements extension points: Filter, Prescore, Score.
NodeName: Checks if a Pod spec node name matches the current node. Extension points: Filter.
NodePorts: Checks if a node has free ports for the requested Pod ports. Extension points: PreFilter, Filter.
NodePreferAvoidPods: Scores nodes according to the node annotation scheduler.alpha.kubernetes.io/preferAvoidPods. Extension points: Score.
NodeAffinity: Implements node selectors and node affinity. Extension points: Filter, Score.
PodTopologySpread: Implements Pod topology spread. Extension points: PreFilter, Filter, PreScore, Score.
NodeUnschedulable: Filters out nodes that have .spec.unschedulable set to true. Extension points: Filter.
NodeResourcesFit: Checks if the node has all the resources that the Pod is requesting. Extension points: PreFilter, Filter.
NodeResourcesBalancedAllocation: Favors nodes that would obtain a more balanced resource usage if the Pod is scheduled there. Extension points: Score.
NodeResourcesLeastAllocated: Favors nodes that have a low allocation of resources. Extension points: Score.
VolumeBinding: Checks if the node has or if it can bind the requested volumes. Extension points: PreFilter, Filter, Reserve, PreBind.
VolumeRestrictions: Checks that volumes mounted in the node satisfy restrictions that are specific to the volume provider. Extension points: Filter.
VolumeZone: Checks that volumes requested satisfy any zone requirements they might have. Extension points: Filter.
NodeVolumeLimits: Checks that CSI volume limits can be satisfied for the node. Extension points: Filter.
EBSLimits: Checks that AWS EBS volume limits can be satisfied for the node. Extension points: Filter.
GCEPDLimits: Checks that GCP-PD volume limits can be satisfied for the node. Extension points: Filter.
AzureDiskLimits: Checks that Azure disk volume limits can be satisfied for the node. Extension points: Filter.
InterPodAffinity: Implements inter-Pod affinity and anti-affinity. Extension points: PreFilter, Filter, PreScore, Score.
PrioritySort: Provides the default priority based sorting. Extension points: QueueSort.
DefaultBinder: Provides the default binding mechanism. Extension points: Bind.
DefaultPreemption: Provides the default preemption mechanism. Extension points: PostFilter.
You can also enable the following plugins, through the component config APIs, that are not enabled by default:

NodeResourcesMostAllocated: Favors nodes that have a high allocation of resources. Extension points: Score.
RequestedToCapacityRatio: Favor nodes according to a configured function of the allocated resources. Extension points: Score.
NodeResourceLimits: Favors nodes that satisfy the Pod resource limits. Extension points: PreScore, Score.
CinderVolume: Checks that OpenStack Cinder volume limits can be satisfied for the node. Extension points: Filter.
NodeLabel: Filters and / or scores a node according to configured label(s). Extension points: Filter, Score.
ServiceAffinity: Checks that Pods that belong to a Service fit in a set of nodes defined by configured labels. This plugin also favors spreading the Pods belonging to a Service across nodes. Extension points: PreFilter, Filter, Score.
```

**Multiple profiles:**

With the following sample configuration, the scheduler will run with two profiles: one with the default plugins and one with all scoring plugins disabled.
```yaml
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: default-scheduler
  - schedulerName: no-scoring-scheduler
    plugins:
      preScore:
        disabled:
        - name: '*'
      score:
        disabled:
        - name: '*'
```

Pods that want to be scheduled according to a specific profile can include the corresponding scheduler name in its .spec.schedulerName.

for Flags:
https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/


## NodeAffinity
# Check the NodeAffinity.yaml

```yaml
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: disktype
        operator: Exists #(This will check if the key exists)

```
Stages
DuringScheduling 

DuringExection


Use Taint toleration and Node Affinity


## Resources Limits

## Resource Requireemnts
CPU = 100 m (mili)
    = 1 (1 CPU/1 Hyperthread)
memory = 256 Mi 
1 ki = 1024 bytes 
1 Mi Mebibyte = 1048576 bytes
1 Gibibyte = 

You can set the same by creatig Limitrange to all namespaces or specific namespace
 
CPU = 1 vCPU
Memory =  512 Mi

Requests
Limits

## Edit a POD

## Editing a pod is possible only for below paramaters
spec.containers[*].image

spec.initContainers[*].image

spec.activeDeadlineSeconds

spec.tolerations

