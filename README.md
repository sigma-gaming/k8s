# Sigma K8S

## Setup dev k3s cluster

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -s -
```

## Setup Talos

1. Generate secrets:

    ```bash
    talosctl gen secrets
    ```

2. Generate configs:

    ```bash
    talosctl gen config primary https://entrypoint.sigma-k8s.app:6443 \
      --config-patch @patches/all.yaml \
      --config-patch-control-plane @patches/control.yaml \
      --with-secrets ./secrets.yaml
    ```

3. Set talosconfig globally:

    ```bash
    CONTROL_NODE_IP=<control-node-ip>
    sed -i '' "s/\[\]/\[$CONTROL_NODE_IP\]/g" talosconfig
    cp talosconfig ~/.talos/config
    ```

4. Apply configs:

    ```bash
    talosctl apply-config -i -f ./controlplane.yaml -n <control-node-ip>
    talosctl apply-config -i -f ./worker.yaml -n <worker-node-ip>
    ```

5. Bootstrap kubernetes:

    ```bash
    talosctl bootstrap -n <node-ip>
    ```

6. Update kubeconfig:

    ```bash
    talosctl kubeconfig -n <node-ip>
    ```

### Update machine configs

```bash
talosctl gen config primary https://entrypoint.sigma-k8s.app:6443 \
  -t controlplane -t worker \
  --config-patch @patches/all.yaml \
  --config-patch-control-plane @patches/control.yaml \
  --with-secrets ./secrets.yaml \
  --force
```

## Setup Cilium

```bash
helm install cilium cilium/cilium --version 1.15.6 \
  --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=true \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup \
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445 \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true
```

## Setup Flux

Bootstrap:

```bash
flux bootstrap github \
  --token-auth \
  --owner=sigma-gaming \
  --repository=k8s \
  --branch=main \
  --path=clusters/primary
```

### Webhook

1. Generate token:

    ```bash
    head -c 12 /dev/urandom | shasum | cut -d ' ' -f1
    ```

2. Insert generated token into `webhook-token` secret manifest (`components/flux-webhook/flux-webhook.yaml`)
3. Reconcile repository
4. Extract webhook url path from Receiver resource status
5. Setup webhook in repository (`https://sigma-k8s.app/webhooks/flux/hook/<hook-path>`)

## Elastic Stack

### Get Elastic user password

```bash
kubectl get secret elasticsearch-es-elastic-user -n elastic-stack -o jsonpath="{.data.elastic}" | base64 -d
```
