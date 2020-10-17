# Generating the Data Encryption Config and Key

Kubernetes stores a variety of data including cluster state, application configurations, and secrets. Kubernetes supports the ability to [encrypt](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data) cluster data at rest.

In this lab you will generate an encryption key and an [encryption config](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration) suitable for encrypting Kubernetes Secrets.

## The Encryption Key

Generate an encryption key:
```
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

## The Encryption Config File

Create the `encryption-config.yaml` encryption config file:
```
cat > encryption-config.yaml << EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
```

### Copy file to other master server
```
declare -A masterarray

masterarray["kubemaster01"]="192.168.2.61"
masterarray["kubemaster02"]="192.168.2.62"

for masternode in ${!masterarray[@]}; do
    scp encryption-config.yaml ${masternode}:~/
done