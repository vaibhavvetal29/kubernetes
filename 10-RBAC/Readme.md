## check kube-apiserver settigns

### Role and ClusterRole

An RBAC _Role_ or _ClusterRole_ contains rules that represent a set of permissions.
Permissions are purely additive (there are no "deny" rules).

A Role always sets permissions within a particular {{< glossary_tooltip text="namespace" term_id="namespace" >}};
when you create a Role, you have to specify the namespace it belongs in.

ClusterRole, by contrast, is a non-namespaced resource.


#### Role example

Here's an example Role in the "default" namespace that can be used to grant read access to

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

#### ClusterRole example

A ClusterRole can be used to grant the same permissions as a Role.
Because ClusterRoles are cluster-scoped, you can also use them to grant access to:

* cluster-scoped resources (like {{< glossary_tooltip text="nodes" term_id="node" >}})
* non-resource endpoints (like `/healthz`)
* namespaced resources (like Pods), across all namespaces
  For example: you can use a ClusterRole to allow a particular user to run
  `kubectl get pods --all-namespaces`.

Here is an example of a ClusterRole that can be used to grant read access to
{{< glossary_tooltip text="secrets" term_id="secret" >}} in any particular namespace,
or across all namespaces (depending on how it is [bound](#rolebinding-and-clusterrolebinding)):

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

### RoleBinding and ClusterRoleBinding

A role binding grants the permissions defined in a role to a user or set of users.
It holds a list of *subjects* (users, groups, or service accounts), and a reference to the
role being granted.
A RoleBinding grants permissions within a specific namespace whereas a ClusterRoleBinding
grants that access cluster-wide.

A RoleBinding may reference any Role in the same namespace. Alternatively, a RoleBinding
can reference a ClusterRole and bind that ClusterRole to the namespace of the RoleBinding.
If you want to bind a ClusterRole to all the namespaces in your cluster, you use a
ClusterRoleBinding.

The name of a RoleBinding or ClusterRoleBinding object must be a valid
[path segment name](/docs/concepts/overview/working-with-objects/names#path-segment-names).

#### RoleBinding examples {#rolebinding-example}

Here is an example of a RoleBinding that grants the "pod-reader" Role to the user "jane"
within the "default" namespace.
This allows "jane" to read pods in the "default" namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
# You can specify more than one "subject"
- kind: User
  name: jane # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```
#### ClusterRoleBinding example

To grant permissions across a whole cluster, you can use a ClusterRoleBinding.
The following ClusterRoleBinding allows any user in the group "manager" to read
secrets in any namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

After you create a binding, you cannot change the Role or ClusterRole that it refers to.
If you try to change a binding's `roleRef`, you get a validation error. If you do want
to change the `roleRef` for a binding, you need to remove the binding object and create
a replacement.



### Aggregated ClusterRoles

You can _aggregate_ several ClusterRoles into one combined ClusterRole.
A controller, running as part of the cluster control plane, watches for ClusterRole
objects with an `aggregationRule` set. The `aggregationRule` defines a label
{{< glossary_tooltip text="selector" term_id="selector" >}} that the controller
uses to match other ClusterRole objects that should be combined into the `rules`
field of this one.

Here is an example aggregated ClusterRole:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-monitoring: "true"
rules: [] # The control plane automatically fills in the rules
```

If you create a new ClusterRole that matches the label selector of an existing aggregated ClusterRole,
that change triggers adding the new rules into the aggregated ClusterRole.
Here is an example that adds rules to the "monitoring" ClusterRole, by creating another
ClusterRole labeled `rbac.example.com/aggregate-to-monitoring: true`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-endpoints
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
# When you create the "monitoring-endpoints" ClusterRole,
# the rules below will be added to the "monitoring" ClusterRole.
rules:
- apiGroups: [""]
  resources: ["services", "endpoints", "pods"]
  verbs: ["get", "list", "watch"]
```



### Referring to subjects

A RoleBinding or ClusterRoleBinding binds a role to subjects.
Subjects can be groups, users or
{{< glossary_tooltip text="ServiceAccounts" term_id="service-account" >}}.

Kubernetes represents usernames as strings.
These can be: plain names, such as "alice"; email-style names, like "bob@example.com";
or numeric user IDs represented as a string.  It is up to you as a cluster administrator
to configure the [authentication modules](/docs/reference/access-authn-authz/authentication/)
so that authentication produces usernames in the format you want.

{{< caution >}}
The prefix `system:` is reserved for Kubernetes system use, so you should ensure
that you don't have users or groups with names that start with `system:` by
accident.
Other than this special prefix, the RBAC authorization system does not require any format
for usernames.
{{< /caution >}}

In Kubernetes, Authenticator modules provide group information.
Groups, like users, are represented as strings, and that string has no format requirements,
other than that the prefix `system:` is reserved.

[ServiceAccounts](/docs/tasks/configure-pod-container/configure-service-account/) have names prefixed
with `system:serviceaccount:`, and belong to groups that have names prefixed with `system:serviceaccounts:`.

{{< note >}}
- `system:serviceaccount:` (singular) is the prefix for service account usernames.
- `system:serviceaccounts:` (plural) is the prefix for service account groups.
{{< /note >}}

#### RoleBinding examples {#role-binding-examples}

The following examples are `RoleBinding` excerpts that only
show the `subjects` section.

For a user named `alice@example.com`:

```yaml
subjects:
- kind: User
  name: "alice@example.com"
  apiGroup: rbac.authorization.k8s.io
```

For a group named `frontend-admins`:

```yaml
subjects:
- kind: Group
  name: "frontend-admins"
  apiGroup: rbac.authorization.k8s.io
```

For the default service account in the "kube-system" namespace:

```yaml
subjects:
- kind: ServiceAccount
  name: default
  namespace: kube-system
```

For all service accounts in the "qa" namespace:

```yaml
subjects:
- kind: Group
  name: system:serviceaccounts:qa
  apiGroup: rbac.authorization.k8s.io
```

For all service accounts in any namespace:

```yaml
subjects:
- kind: Group
  name: system:serviceaccounts
  apiGroup: rbac.authorization.k8s.io
```

For all authenticated users:

```yaml
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
```

For all unauthenticated users:

```yaml
subjects:
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
```

For all users:

```yaml
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
```
## Command-line utilities

### `kubectl create role`

Creates a Role object defining permissions within a single namespace. Examples:

* Create a Role named "pod-reader" that allows users to perform `get`, `watch` and `list` on pods:

    ```shell
    kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods
    ```

* Create a Role named "pod-reader" with resourceNames specified:

    ```shell
    kubectl create role pod-reader --verb=get --resource=pods --resource-name=readablepod --resource-name=anotherpod
    ```

* Create a Role named "foo" with apiGroups specified:

    ```shell
    kubectl create role foo --verb=get,list,watch --resource=replicasets.apps
    ```

* Create a Role named "foo" with subresource permissions:

    ```shell
    kubectl create role foo --verb=get,list,watch --resource=pods,pods/status
    ```

* Create a Role named "my-component-lease-holder" with permissions to get/update a resource with a specific name:

    ```shell
    kubectl create role my-component-lease-holder --verb=get,list,watch,update --resource=lease --resource-name=my-component
    ```

### `kubectl create clusterrole`

Creates a ClusterRole. Examples:

* Create a ClusterRole named "pod-reader" that allows user to perform `get`, `watch` and `list` on pods:

    ```shell
    kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods
    ```

* Create a ClusterRole named "pod-reader" with resourceNames specified:

    ```shell
    kubectl create clusterrole pod-reader --verb=get --resource=pods --resource-name=readablepod --resource-name=anotherpod
    ```

* Create a ClusterRole named "foo" with apiGroups specified:

    ```shell
    kubectl create clusterrole foo --verb=get,list,watch --resource=replicasets.apps
    ```

* Create a ClusterRole named "foo" with subresource permissions:

    ```shell
    kubectl create clusterrole foo --verb=get,list,watch --resource=pods,pods/status
    ```

* Create a ClusterRole named "foo" with nonResourceURL specified:

    ```shell
    kubectl create clusterrole "foo" --verb=get --non-resource-url=/logs/*
    ```

* Create a ClusterRole named "monitoring" with an aggregationRule specified:

    ```shell
    kubectl create clusterrole monitoring --aggregation-rule="rbac.example.com/aggregate-to-monitoring=true"
    ```

### `kubectl create rolebinding`

Grants a Role or ClusterRole within a specific namespace. Examples:

* Within the namespace "acme", grant the permissions in the "admin" ClusterRole to a user named "bob":

    ```shell
    kubectl create rolebinding bob-admin-binding --clusterrole=admin --user=bob --namespace=acme
    ```

* Within the namespace "acme", grant the permissions in the "view" ClusterRole to the service account in the namespace "acme" named "myapp":

    ```shell
    kubectl create rolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp --namespace=acme
    ```

* Within the namespace "acme", grant the permissions in the "view" ClusterRole to a service account in the namespace "myappnamespace" named "myapp":

    ```shell
    kubectl create rolebinding myappnamespace-myapp-view-binding --clusterrole=view --serviceaccount=myappnamespace:myapp --namespace=acme
    ```

### `kubectl create clusterrolebinding`

Grants a ClusterRole across the entire cluster (all namespaces). Examples:

* Across the entire cluster, grant the permissions in the "cluster-admin" ClusterRole to a user named "root":

    ```shell
    kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=cluster-admin --user=root
    ```

* Across the entire cluster, grant the permissions in the "system:node-proxier" ClusterRole to a user named "system:kube-proxy":

    ```shell
    kubectl create clusterrolebinding kube-proxy-binding --clusterrole=system:node-proxier --user=system:kube-proxy
    ```

* Across the entire cluster, grant the permissions in the "view" ClusterRole to a service account named "myapp" in the namespace "acme":

    ```shell
    kubectl create clusterrolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp
    ```

### `kubectl auth reconcile` {#kubectl-auth-reconcile}

Creates or updates `rbac.authorization.k8s.io/v1` API objects from a manifest file.

Missing objects are created, and the containing namespace is created for namespaced objects, if required.

Existing roles are updated to include the permissions in the input objects,
and remove extra permissions if `--remove-extra-permissions` is specified.

Existing bindings are updated to include the subjects in the input objects,
and remove extra subjects if `--remove-extra-subjects` is specified.

Examples:

* Test applying a manifest file of RBAC objects, displaying changes that would be made:

    ```
    kubectl auth reconcile -f my-rbac-rules.yaml --dry-run=client
    ```

* Apply a manifest file of RBAC objects, preserving any extra permissions (in roles) and any extra subjects (in bindings):

    ```shell
    kubectl auth reconcile -f my-rbac-rules.yaml
    ```

* Apply a manifest file of RBAC objects, removing any extra permissions (in roles) and any extra subjects (in bindings):

    ```shell
    kubectl auth reconcile -f my-rbac-rules.yaml --remove-extra-subjects --remove-extra-permissions
    ```

## ServiceAccount permissions {#service-account-permissions}

Default RBAC policies grant scoped permissions to control-plane components, nodes,
and controllers, but grant *no permissions* to service accounts outside the `kube-system` namespace
(beyond discovery permissions given to all authenticated users).

This allows you to grant particular roles to particular ServiceAccounts as needed.
Fine-grained role bindings provide greater security, but require more effort to administrate.
Broader grants can give unnecessary (and potentially escalating) API access to
ServiceAccounts, but are easier to administrate.

In order from most secure to least secure, the approaches are:

1. Grant a role to an application-specific service account (best practice)

    This requires the application to specify a `serviceAccountName` in its pod spec,
    and for the service account to be created (via the API, application manifest, `kubectl create serviceaccount`, etc.).

    For example, grant read-only permission within "my-namespace" to the "my-sa" service account:

    ```shell
    kubectl create rolebinding my-sa-view \
      --clusterrole=view \
      --serviceaccount=my-namespace:my-sa \
      --namespace=my-namespace
    ```

2. Grant a role to the "default" service account in a namespace

    If an application does not specify a `serviceAccountName`, it uses the "default" service account.

    {{< note >}}
    Permissions given to the "default" service account are available to any pod
    in the namespace that does not specify a `serviceAccountName`.
    {{< /note >}}

    For example, grant read-only permission within "my-namespace" to the "default" service account:

    ```shell
    kubectl create rolebinding default-view \
      --clusterrole=view \
      --serviceaccount=my-namespace:default \
      --namespace=my-namespace
    ```

    Many [add-ons](/docs/concepts/cluster-administration/addons/) run as the
    "default" service account in the `kube-system` namespace.
    To allow those add-ons to run with super-user access, grant cluster-admin
    permissions to the "default" service account in the `kube-system` namespace.

    {{< caution >}}
    Enabling this means the `kube-system` namespace contains Secrets
    that grant super-user access to your cluster's API.
    {{< /caution >}}

    ```shell
    kubectl create clusterrolebinding add-on-cluster-admin \
      --clusterrole=cluster-admin \
      --serviceaccount=kube-system:default
    ```

3. Grant a role to all service accounts in a namespace

    If you want all applications in a namespace to have a role, no matter what service account they use,
    you can grant a role to the service account group for that namespace.

    For example, grant read-only permission within "my-namespace" to all service accounts in that namespace:

    ```shell
    kubectl create rolebinding serviceaccounts-view \
      --clusterrole=view \
      --group=system:serviceaccounts:my-namespace \
      --namespace=my-namespace
    ```

4. Grant a limited role to all service accounts cluster-wide (discouraged)

    If you don't want to manage permissions per-namespace, you can grant a cluster-wide role to all service accounts.

    For example, grant read-only permission across all namespaces to all service accounts in the cluster:

    ```shell
    kubectl create clusterrolebinding serviceaccounts-view \
      --clusterrole=view \
     --group=system:serviceaccounts
    ```

5. Grant super-user access to all service accounts cluster-wide (strongly discouraged)

    If you don't care about partitioning permissions at all, you can grant super-user access to all service accounts.

    {{< warning >}}
    This allows any application full access to your cluster, and also grants
    any user with read access to Secrets (or the ability to create any pod)
    full access to your cluster.
    {{< /warning >}}

    ```shell
    kubectl create clusterrolebinding serviceaccounts-cluster-admin \
      --clusterrole=cluster-admin \
      --group=system:serviceaccounts
    ```
