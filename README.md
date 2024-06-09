## Install Nginx Ingress Controller

```bash
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    --set controller.hostNetwork=true \
    --set controller.hostPort.enabled=true \
    --set controller.admissionWebhooks.certManager.enabled=true \
    --set controller.kind=DaemonSet \
    --set controller.tolerations[0].key=node-role.kubernetes.io/control-plane \
    --set controller.tolerations[0].operator=Exists \
    --set controller.tolerations[0].effect=NoSchedule
```