# DevOps Secrets Training

> [!IMPORTANT]
> Disclaimer: I specify Azure, AKS, Vault, ..etc. because, its what I have experience with.
> The tools discussed today can be used in any environment.  

> [!IMPORTANT]
> Disclaimer: The code in shell script was put together using example code found in various resources. 
> These resources have been mentioned in the references section of this document. 
> The sole purpose of the shell script is for demo and self-paced practice. 

> [!CAUTION]
> Steps used in the demo are meant only for educational purposes.
> They should not be used in production. Please follow best practices when deploying to production.

## Requirements

1. https://github.com/
1. https://killercoda.com/playgrounds/
1. Understanding of basic concepts of git, github, kubernetes, shell (bash)
1. Paitence to read to many, huge reference documents and online tutorials
1. Interest/ time to play around in online playgrounds

## Setup Instructions

1. Create/ Login into your github/ gitlab account
    1. Create a personal access token 
1. Login into k8s playground: https://killercoda.com/playgrounds/scenario/kubernetes
    1. Change in the repo directory: `cd devops-secrets-training`
1. Clone tutorial repo: https://github.com/surya-melarkode/devops-secrets-training
1. Make the helper scripts executable: e.g. `chmod +x sealed-secrets.sh`

### Sealed Secrets Tutorial

1. Setup & deploy sealed secrets controller: `bash -c "source sealed-secrets.sh; setup_sealed_secrets"`
1. Setup kubeseal client: `bash -c "source sealed-secrets.sh; setup_kubeseal"`
1. Create a sealed secret: `bash -c "source sealed-secrets.sh; create_sealed_secret"`
1. Inspect the sealed secret: `bash -c "source sealed-secrets.sh; inspect_sealed_secret"`
1. Decrypt the secret (not sealed secret): `bash -c "source sealed-secrets.sh; decrypt_secret"`

### Vault Tutorial
1. Setup vault: `bash -c "source vault.sh; setup_vault"`
1. Unseal vault: `bash -c "source vault.sh; unseal_vault"`
1. Create vault webapp secret: `bash -c "source vault.sh; create_webapp_vault_secret"`
1. Uncomment each command in `vault.sh` and execute them in the terminal
    1. List all available resource: `kubectl get all,cm,secret,ing -A`
    1. Here you will log into vault-0: `kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh`
    1. Configure Kubernetes authentication - Vault provides a Kubernetes authentication method that enables clients to authenticate with a Kubernetes Service Account Token `vault auth enable kubernetes`
    1. Tell vault where to find the k8s cluster `vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"`
    1. Create a policy that allows "read"
    ```
    vault policy write webapp - <<EOF
    path "secret/data/webapp/config" {
    capabilities = ["read"]
    }
    EOF
    ```
    1. Create a Kubernetes authentication role, named webapp, that connects the Kubernetes service account name and webapp policy
    ```
    vault write auth/kubernetes/role/webapp \
        bound_service_account_names=vault \
        bound_service_account_namespaces=default \
        policies=webapp \
        ttl=24h
    ```
    1. Create the webapp deployment k8s and verify the pod is running, `kubectl apply --filename deployment-01-webapp.yml` and `kubectl get all,cm,secret,ing -A`
    1. Port the localhost:8080 to web app pod: `kubectl port-forward $(kubectl get pod -l app=webapp -o jsonpath="{.items[0].metadata.name}") 
    8080:8080`
    1. Verify that vault secret can be access by webapp pod: `curl http://localhost:8080`

### SOPS Tutorial
1. Download into vault: `wget https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64`
1. Move the binary in to your PATH: `mv sops-v3.9.0.linux.amd64 /usr/local/bin/sops`
1. Make the binary executable: `chmod +x /usr/local/bin/sops`
1. Log into vault-0 again: `kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh`
    1. Set the environment variable: `export VAULT_ADDR=http://127.0.0.1:8200`
    1. Verify the vault status: `vault status`
    1. Enable a transit secret engine for sops: `vault secrets enable -path=sops transit`
    1. Create sample keys:
        1. `vault write sops/keys/firstkey type=rsa-4096`
        1. `vault write sops/keys/secondkey type=rsa-2048`
        1. `vault write sops/keys/thirdkey type=chacha20-poly1305`
    1. Create an encrypted secret file: `sops --hc-vault-transit $VAULT_ADDR/v1/sops/keys/firstkey example.yml`

## References

1. https://github.com/surya-melarkode/devops-secrets-training
1. https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#installation
1. https://killercoda.com/playgrounds/scenario/kubernetes
1. https://www.digitalocean.com/community/developer-center/how-to-encrypt-kubernetes-secrets-using-sealed-secrets-in-doks
1. https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-minikube-raft
