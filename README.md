# Sigma K8S

## Create registry credentials secret

```bash
kubectl create secret docker-registry google-registry-creds \
  --docker-server europe-west4-docker.pkg.dev \
  --docker-username _json_key \
  --docker-email google-registry@sigma-k8s.app \
  --docker-password="$(cat ./key.json)" \
  --dry-run=client -o yaml
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
