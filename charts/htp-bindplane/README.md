# Honeycomb Telemetry Pipeline - Bindplane

This helm chart installs the Honeycomb Telemetry Pipeline - Bindplane in a Kubernetes cluster.
The only requirement is a License Key.

## Prerequisites

Helm 3.0+
Kubernetes 1.24+

## Installing the Chart

### Add helm repo

```sh
helm repo add honeycomb https://honeycombio.github.io/helm-charts
```

### Install helm chart with secret

The chart is set up to look for a secret called `hny-secrets`.

```sh
export LICENSE_KEY='your-license-key'

kubectl create secret generic hny-secrets \
  --from-literal=license=$LICENSE_KEY \
  --from-literal=sessions_secret=$(uuidgen) \
  --from-literal=username=admin \
  --from-literal=password=admin

helm install htp-bindplane honeycomb/htp-bindplane
```

### Install helm chart with hard-coded secrets

If you cannot use secrets you can set the license key directly when installing the chart:

```sh
export LICENSE_KEY='your-license-key'

helm install htp-bindplane honeycomb/htp-bindplane \
  --set htp.config.licenseUseSecret=false \
  --set htp.config.license=$LICENSE_KEY \
  --set htp.config.sessions_secret=$(uuidgen) \
  --set htp.config.username='admin' \
  --set htp.config.password='admin'
```

### Port-forward to view in UI

```sh
kubectl port-forward svc/htp-bindplane 3001
```

By default the helm chart sets the username to `admin` and the password to `admin`.

## Values

See the [subchart's values.yaml](https://github.com/observIQ/bindplane-op-helm/blob/main/charts/bindplane/values.yaml) for details.
