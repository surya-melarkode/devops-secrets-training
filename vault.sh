#!/usr/bin/env bash

setup_vault() {
    helm repo add hashicorp "https://helm.releases.hashicorp.com";
    helm install vault hashicorp/vault;
    kubectl get pods -A;
    echo "Sleeping for 30 seconds. Waiting for vault service to start..."
    sleep 30;
    kubectl exec vault-0 -- vault status;
    kubectl logs vault-0
}

unseal_vault() {
    kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json;
    VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]");
    kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY;
    kubectl get pods -A;
    cat cluster-keys.json | jq -r ".root_token";
}

create_webapp_vault_secret() {
    kubectl exec -it vault-0 -- ash -c "vault login $(cat cluster-keys.json | jq -r '.root_token') \
        && vault secrets enable -path=secret kv-v2 \
        && vault kv put secret/webapp/config username='static-user' password='static-password' \
        && vault kv get secret/webapp/config"
}

configure_k8s_authN() {
    kubectl exec -it vault-0 -- ash -c "vault auth enable kubernetes \
    && vault write auth/kubernetes/config kubernetes_host='https://$KUBERNETES_PORT_443_TCP_ADDR:443'\
    && vault policy write webapp - <<EOF
        path \"secret/data/webapp/config\" {
        capabilities = [\"read\"]
        }
        EOF \
    && vault write auth/kubernetes/role/webapp \
        bound_service_account_names=vault \
        bound_service_account_namespaces=default \
        policies=webapp \
        ttl=24h"
}

VAULT_POLICY=$(cat vault-policy.txt); kubectl exec -it vault-0 -- ash -c "vault policy write webapp - $VAULT_POLICY" \
&& vault write auth/kubernetes/role/webapp \
bound_service_account_names=vault \
bound_service_account_namespaces=default \
policies=webapp \
ttl=24h"