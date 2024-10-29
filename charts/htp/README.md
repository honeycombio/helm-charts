# Honeycomb Telemetry Pipeline

This installs the Honeycomb Telemetry Pipeline.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.0+

## Installing the Chart

### Add helm repo

```sh
helm repo add honeycomb https://honeycombio.github.io/helm-charts
```

### Install helm chart with hard-coded secrets

The easiest way to install the chart is by setting the license key directly:

```sh
export LICENSE_KEY='your-license-key'

helm install htp honeycomb/htp \
  --set htp.config.licenseUseSecret=false \
  --set htp.config.license=$LICENSE_KEY \
  --set htp.config.username='admin' \
  --set htp.config.password='admin' \
  --set htp.config.sessions_secret=$(uuidgen)
```

### Install helm chart with Kubernetes secret

The best practice is to manage your secret separately.
The chart is set up to look for a secret called `hny-secrets`.

```sh
export LICENSE_KEY='your-license-key'

kubectl create secret generic hny-secrets \
  --from-literal=license=$LICENSE_KEY \
  --from-literal=username=admin \
  --from-literal=password=admin \
  --from-literal=sessions_secret=$(uuidgen)

helm install htp honeycomb/htp
```

### Port-forward to view in UI

```sh
kubectl port-forward svc/htp 3001
```
