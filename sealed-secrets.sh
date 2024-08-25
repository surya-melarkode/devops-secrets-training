#!/usr/bin/env bash

setup_sealed_secrets() {
    helm repo add sealed-secrets "https://bitnami-labs.github.io/sealed-secrets"
    helm install sealed-secrets -n kube-system --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets
}

setup_kubeseal() {
    KUBESEAL_VERSION='0.27.1' 
    curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION:?}/kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz"
    tar -xvzf kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz kubeseal
    sudo install -m 755 kubeseal /usr/local/bin/kubeseal
}

create_sealed_secret() {
    kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --fetch-cert > mycert.pem
    kubectl create secret generic demo-secret --dry-run=client --from-literal=foo=bar -o yaml
    kubectl create secret generic demo-secret --dry-run=client --from-literal=foo=bar -o yaml  \
        | kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --format yaml --cert mycert.pem > mysealedsecret.yaml
    kubectl create -f mysealedsecret.yaml
}

inspect_sealed_secret() {
    kubectl get sealedsecret demo-secret -o yaml
}

validate_sealed_secret() {
    cat mysealedsecret.yaml | kubeseal --validate && echo 'Validate Sealed Secret!'    
}

decrypt_secret() {
    kubectl get secret demo-secret -o yaml
}
