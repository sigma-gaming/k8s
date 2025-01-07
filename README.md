# Sigma K8S

## Create registry credentials secret

```bash
kubectl create secret docker-registry google-registry-creds \
  --docker-server europe-west1-docker.pkg.dev \
  --docker-username _json_key \
  --docker-email google-registry@sigma-k8s.app \
  --docker-password="$(cat ./key.json)" \
  --dry-run=client -o yaml
```

## Create cloudflare certificate

1. In "Origin server" section, create a certificate for the domain
2. Download the certificate and key, and save them to `certificates/$DOMAIN.pem` and `certificates/$DOMAIN.key`
3. Create a secret manifest:

```fish
set CLUSTER cluster
set DOMAIN example.com

kubectl create secret tls $DOMAIN-cloudflare-cert \
  --cert=./certificates/$DOMAIN.pem \
  --key=./certificates/$DOMAIN.key \
  --dry-run=client -o yaml > ./certificates/$DOMAIN-cloudflare-cert.yaml

seal_file $CLUSTER ./certificates/$DOMAIN-cloudflare-cert.yaml cluster-wide
```

## Kubeseal

Get public key:

```bash
kubeseal --fetch-cert \
  --controller-name=sealed-secrets \
  --controller-namespace=sealed-secrets \
  > pub-sealed-secrets.pem
```

Seal a secret:

```bash
kubeseal --format=yaml --cert=clusters/<cluster>/pub-sealed-secrets.pem < basic-auth.yaml > basic-auth-sealed.yaml
```

## Setup Flux

Bootstrap:

```bash
flux bootstrap github \
  --token-auth \
  --owner=sigma-gaming \
  --repository=k8s \
  --branch=main \
  --path=clusters/<cluster> \
  --components-extra image-reflector-controller,image-automation-controller
```

### Webhook

1. Generate token:

    ```bash
    head -c 12 /dev/urandom | shasum | cut -d ' ' -f1
    ```

2. Insert generated token into `webhook-token` secret manifest (`cluster-components/<cluster>/flux-webhook/flux-webhook.yaml`)
3. Reconcile repository
4. Extract webhook url path from Receiver resource status
5. Setup webhook in repository (`https://sigma-k8s.app/webhooks/flux/hook/<hook-path>`)
