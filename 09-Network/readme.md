### Kubernetes networking addresses four concerns:
   a. Containers within a Pod use networking to communicate via loopback.
   b. Cluster networking provides communication between different Pods.
   c. The Service resource lets you expose an application running in Pods to be reachable from outside your cluster.
   d. You can also use Services to publish services only for consumption inside your cluster.

### Communications
> 1) Intra-pod (container to container)
> 2) Inter-pod (pod to pod)
        a) Pods can communicate directly without the help of network address translation, tunnels, proxies, or any other obfuscating layer.
        b) But not Exposed to outside world 
> 3) Pod-to-service
        a) for external communication

### Service
   a Service is an abstraction which defines a logical set of Pods and a policy by which to access them (sometimes this pattern is called a micro-service). The set of Pods targeted by a Service is usually determined by a selector 

#### Note: A Service can map any incoming port to a targetPort. By default and for convenience, the targetPort is set to the same value as the port field.

#### Services without selectors
    Services most commonly abstract access to Kubernetes Pods, but they can also abstract other kinds of backends. For example:
        You want to have an external database cluster in production, but in your test environment you use your own databases.
        You want to point your Service to a Service in a different Namespace or on another cluster.
        You are migrating a workload to Kubernetes. While evaluating the approach, you run only a proportion of your backends in Kubernetes.



### Application protocol
FEATURE STATE: Kubernetes v1.19 [beta]
The AppProtocol field provides a way to specify an application protocol for each Service port. The value of this field is mirrored by corresponding Endpoints and EndpointSlice resources

### Virtual IPs and service proxies
Every node in a Kubernetes cluster runs a kube-proxy. kube-proxy is responsible for implementing a form of virtual IP for Services of type other than ExternalName

### Commands
kubectl create service nodeport myservice --tcp=80:80 --nodeport=30000 --dry-run=client -o yaml>myservice.yaml

# --tcp (port:targetport) 

### Headless Services
Sometimes you don't need load-balancing and a single Service IP. In this case, you can create what are termed "headless" Services, by explicitly specifying "None" for the cluster IP (.spec.clusterIP).
For headless Services, a cluster IP is not allocated, kube-proxy does not handle these Services, and there is no load balancing or proxying done by the platform for them

#### With selectors
For headless Services that define selectors, the endpoints controller creates Endpoints records in the API, and modifies the DNS configuration to return records (addresses) that point directly to the Pods backing the Service.

#### Without selectors
For headless Services that do not define selectors, the endpoints controller does not create Endpoints records. However, the DNS system looks for and configures either:

> a. CNAME records for ExternalName-type Services.
> b. A records for any Endpoints that share a name with the Service, for all other types.


### Choosing your own IP address
You can specify your own cluster IP address as part of a Service creation request. To do this, set the .spec.clusterIP field. For example, if you already have an existing DNS entry that you wish to reuse, or legacy systems that are configured for a specific IP address and difficult to re-configure.

The IP address that you choose must be a valid IPv4 or IPv6 address from within the service-cluster-ip-range CIDR range that is configured for the API server.

### Types of Service
> a. ClusterIP
        Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default ServiceType.
> b. NodePort (30000-32767) (--nodeport-addresses)
        Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting <NodeIP>:<NodePort>.
> c. LoadBalancer
        Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.
> d. ExternalName
        Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up.



Check https://kubernetes.io/docs/concepts/services-networking/service/ for more info specific cloud provider load balancing solution


```yaml
sudo iptables -nvL -t nat | grep 30007
sudo iptables -nvL -t nat | grep KUBE-SVC-ZYPCWJFX4JQYFUVC -A 10
sudo iptables -nvL -t nat | grep KUBE-SEP-VBVQIMXMCYU2YY5O -A 3

ip route show


```


### Exposing a Service with ExternalIPs
kubectl  get svc

edit the same

  type: NodePort
  externalIPs:
    - xx.xx.xx.xx
    - yy.yy.yy.yy


### DNS
Services
    my-svc.my-namespace.svc.cluster-domain.example
Pods
    pod-ip-address.my-namespace.pod.cluster-domain.example

### Pod's DNS Policy
DNS policies can be set on a per-pod basis. Currently Kubernetes supports the following pod-specific DNS policies. These policies are specified in the dnsPolicy field of a Pod Spec.

"Default": The Pod inherits the name resolution configuration from the node that the pods run on. See related discussion for more details.
"ClusterFirst": Any DNS query that does not match the configured cluster domain suffix, such as "www.kubernetes.io", is forwarded to the upstream nameserver inherited from the node. Cluster administrators may have extra stub-domain and upstream DNS servers configured. See related discussion for details on how DNS queries are handled in those cases.
"ClusterFirstWithHostNet": For Pods running with hostNetwork, you should explicitly set its DNS policy "ClusterFirstWithHostNet".
"None": It allows a Pod to ignore DNS settings from the Kubernetes environment. All DNS settings are supposed to be provided using the dnsConfig field in the Pod Spec. See Pod's DNS config subsection below.

>> Note: "Default" is not the default DNS policy. If dnsPolicy is not explicitly specified, then "ClusterFirst" is used.


Environment variable
kubectl exec myappdp-5bc4d4fb84-fpg7t -- printenv | grep SERVICE
myappdp-5bc4d4fb84-jctzs
kubectl exec myappdp-5bc4d4fb84-jctzs -- printenv | grep SERVICE



## INGRESS We will check this one we will upgrade cluster to 1.19
