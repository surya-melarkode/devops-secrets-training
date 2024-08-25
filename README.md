# DevOps Secrets Training

> [!CAUTION]
> Steps used in the demo are meant only for educational purposes.
> They should not be used in production. Please follow best practices when deploying to production.

## Requirements

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

1. Setup & deploy sealed secrets controller: `./sealed-secrets.sh;setup_sealed_secrets`
1. Setup kubeseal client: `./sealed-secrets.sh;setup_kubeseal`
1. Create a sealed secret: `./sealed-secrets.sh;create_sealed_secret`
1. Inspect the sealed secret: `./sealed-secrets.sh;inspect_sealed_secret`
1. Decrypt the secret (not sealed secret): `./sealed-secrets.sh;decrypt_secret`

## References

1. https://github.com/surya-melarkode/devops-secrets-training
1. https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#installation
1. https://killercoda.com/playgrounds/scenario/kubernetes