
list_k8s_resources() {
    kubectl get all,cm,secret,ing -A
}