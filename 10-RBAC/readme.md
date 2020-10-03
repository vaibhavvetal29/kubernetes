## To manage RBAC in Kubernetes, we need to declare:

### Role and ClusterRole
    They are just a set of rules that represent a set of permissions. A Role can only be used to grant access to resources within namespaces. A ClusterRole can be used to grant the same permissions as a Role but they can also be used to grant access to cluster-scoped resources, non-resource endpoints.
### Subjects
    A subject is the entity that will make operations in the cluster. They can be user accounts, services accounts or even a group.
### RoleBinding and ClusterRoleBinding
    As the name implies, it’s just the binding between a subject and a Role or a ClusterRole.

## The default Roles defined in Kubernetes are:
    view: read-only access, excludes secrets
    edit: above + ability to edit most resources, excludes roles and role bindings
    admin: above + ability to manage roles and role bindings at a namespace level
    cluster-admin: everything

## They are multiple ways of managing normal users:

Basic Authentication:
    Pass a configuration with content like the following to API Server
    password,username,uid,group
X.509 client certificate
    Create a user’s private key and a certificate signing request
    Get it certified by a CA (Kubernetes CA) to have the user’s certificate
Bearer Tokens (JSON Web Tokens)
    OpenID Connect
    On top of OAuth 2.0
    Webhooks

`sudo adduser dineshdev1 `
`passwd dineshdev1`
## test@123

## create user credentials
    openssl genrsa -out dineshdev1.key 2048
###  Create CSR 
    # Without Group
        openssl req -new -key dineshdev1.key \
        -out dineshdev1.csr \
        -subj "/CN=dineshdev1"

# With a Group where $group is the group name
        openssl req -new -key dineshdev1.key \
        -out dineshdev1.csr \
        -subj "/CN=dineshdev1/O=$group"


### Sign the CSR with the Kubernetes CA
openssl x509 -req -in dineshdev1.csr \
-CA /etc/kubernetes/pki/ca.crt \
-CAkey /etc/kubernetes/pki/ca.key \
-CAcreateserial \
-out dineshdev1.crt -days 500


### Create context
kubectl config set-context dineshdev1-context \
--cluster=kubernetes --user=dineshdev1

add certificates in the config

copy the file to that user .kube folder
sudo cp /home/dinesh/.kube/config /home/dineshdev1/.kube/config
sudo chown -R dineshdev1: /home/dineshdev1