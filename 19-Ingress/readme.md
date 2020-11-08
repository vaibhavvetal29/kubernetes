## What is Ingress?

**Ingress** exposes HTTP and HTTPS routes from outside the cluster to
service within the cluster.
Traffic routing is controlled by rules defined on the Ingress resource.


An Ingress may be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL / TLS, and offer name-based virtual hosting. An **Ingress controller** is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

An Ingress does not expose arbitrary ports or protocols. Exposing services other than HTTP and HTTPS to the internet typically
uses a service of type **Service.Type=NodePort** or
**Service.Type=LoadBalancer** .

## Key Things about Ingress Object
> 1) You should create ingress rules in the same namespace where you have the services deployed. You cannot route traffic to a service in a different namespace where you don’t have the ingress object
> 2) An ingress object requires an ingress controller for routing traffic.
> 3) External traffic will not hit the ingress API, instead, it will hit the ingress controller service

## Prerequisites

You must have an [Ingress controller](/docs/concepts/services-networking/ingress-controllers) to satisfy an Ingress. Only creating an Ingress resource has no effect.

You may need to deploy an Ingress controller such as [ingress-nginx](https://kubernetes.github.io/ingress-nginx/deploy/). You can choose from a number of
[Ingress controllers](/docs/concepts/services-networking/ingress-controllers).

Ideally, all Ingress controllers should fit the reference specification. In reality, the various Ingress
controllers operate slightly differently.

Refer below Config
[minimal-ingressconfig](/19-Ingress/01-ingress-minimal.yaml)


### Ingress rules

Each HTTP rule contains the following information:

* An optional host. In this example, no host is specified, so the rule applies to all inbound
  HTTP traffic through the IP address specified. If a host is provided (for example,
  foo.bar.com), the rules apply to that host.
* A list of paths (for example, `/testpath`), each of which has an associated
  backend defined with a `service.name` and a `service.port.name` or
  `service.port.number`. Both the host and path must match the content of an
  incoming request before the load balancer directs traffic to the referenced
  Service.
* A backend is a combination of Service and port names as described in the
  [Service doc](/docs/concepts/services-networking/service/) or a [custom resource backend](#resource-backend) by way of a {{< glossary_tooltip term_id="CustomResourceDefinition" text="CRD" >}}. HTTP (and HTTPS) requests to the
  Ingress that matches the host and path of the rule are sent to the listed backend.

A `defaultBackend` is often configured in an Ingress controller to service any requests that do not
match a path in the spec.

### DefaultBackend {#default-backend}

An Ingress with no rules sends all traffic to a single default backend. The `defaultBackend` is conventionally a configuration option
of the [Ingress controller](/docs/concepts/services-networking/ingress-controllers) and is not specified in your Ingress resources.

If none of the hosts or paths match the HTTP request in the Ingress objects, the traffic is
routed to your default backend.

### Resource backends {#resource-backend}

A `Resource` backend is an ObjectRef to another Kubernetes resource within the
same namespace as the Ingress object. A `Resource` is a mutually exclusive
setting with Service, and will fail validation if both are specified. A common
usage for a `Resource` backend is to ingress data to an object storage backend
with static assets.

## Kubernetes Ingress Controller
Ingress controller is typically a proxy service deployed in the cluster. It is nothing but a kubernetes deployment exposed to a service. Following are the ingress controllers available for kubernetes.

[Check for Ingress Controllers available](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/#additional-controllers)



Generally, Nginx is widely used as an ingress controller. Here is how an Nginx ingress controller works.

> 1) The nginx.conf file inside the Nginx controller pod is a go template which can talk to Kubernetes ingress API and get the latest values for traffic routing in real time.
> 2) The Nginx controller talks to Kubernetes ingress API to check if there is any rule created for traffic routing.
> 3) If it finds any ingress rules, it will be applied to the Nginx controller configuration, that is a nginx.conf file inside the pod using the go template.

## Ingress Controller URL (Official)
https://github.com/kubernetes/ingress-nginx/blob/master/deploy/static/provider/baremetal/deploy.yaml

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.0/deploy/static/provider/baremetal/deploy.yaml`

`kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --watch`

## Detect installed version
To detect which version of the ingress controller is running, exec into the pod and run nginx-ingress-controller version command.

```ssh
POD_NAMESPACE=ingress-nginx  

POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -l app.kubernetes.io/name=ingress-nginx --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress-controller --version
```


## Setup LoadBalancer Service For Ingress Controller

kubectl apply -f kubernetes/19-Ingress/02-ingress-controller-service.yaml 

kubectl get svc -n ingress-nginx


## Create demo app

[Refer App](/19-Ingress/03-demo-app.yaml)

## check if app is up
kubectl get deployments,svc -n dev


## Now it's time to create Ingress object

The Ingress spec has all the information needed to configure a load balancer or proxy server. Most importantly, it contains a list of rules matched against all incoming requests. Ingress resource only supports rules for directing HTTP(S) traffic.

## Ingress rules
#### Each HTTP rule contains the following information:

> 1) An optional host. In this example, no host is specified, so the rule applies to all inbound HTTP traffic through the IP address specified. If a host is provided (for example, foo.bar.com), the rules apply to that host.
> 2) A list of paths (for example, /testpath), each of which has an associated backend defined with a service.name and a service.port.name or service.port.number. Both the host and path must match the content of an incoming request before the load balancer directs traffic to the referenced Service.
> 3) A backend is a combination of Service and port names as described in the Service doc or a custom resource backend by way of a CRD. HTTP (and HTTPS) requests to the Ingress that matches the host and path of the rule are sent to the listed backend.

A defaultBackend is often configured in an Ingress controller to service any requests that do not match a path in the spec.


### DefaultBackend
An Ingress with no rules sends all traffic to a single default backend. The defaultBackend is conventionally a configuration option of the Ingress controller and is not specified in your Ingress resources.

If none of the hosts or paths match the HTTP request in the Ingress objects, the traffic is routed to your default backend.

### Resource backends
A **Resource backend** is an ObjectRef to another Kubernetes resource within the same namespace as the Ingress object. A Resource is a mutually exclusive setting with Service, and will fail validation if both are specified.

ssh -t dinesh@192.168.2.73 sudo mkdir /var/lib/wordpressmysql