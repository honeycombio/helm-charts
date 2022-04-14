# Local Development

## Refinery

Prerequisites:
- local kubernetes cluster (Docker for Mac comes with one)
- helm

Installing the Refinery chart:
```shell
cd charts/refinery
helm install refinery .
```

Configuring Ingress Locally:
- install [nginx ingress controller](https://kubernetes.github.io/ingress-nginx/deploy/)
- enable ingress in `values.yaml`
```yaml
ingress:
  enabled: true
  labels: {}
  annotations:
    kubernetes.io/ingress.class: nginx
```

If you now run
```shell
kubectl get ingress
```
You should see something like:

| NAME     | CLASS  | HOSTS          | ADDRESS   | PORTS | AGE   |
|----------|--------|----------------|-----------|-------|-------|
| refinery | <none> | refinery.local | localhost | 80    | 9m43s |

If you don't see an address, check the ingress controller logs:

```shell
kubectl --namespace=ingress-nginx get pods
kubectl --namespace=ingress-nginx logs pods/ingress-nginx-controller-XYZ
```

- add `127.0.0.1 refinery.local` to `/etc/hosts`
- you can now connect to refinery at `refinery.local:80` from your machine
