# Honeycomb Observability Pipeline

This is a WIP helm chart that can install both the OpenTelemetry Collector and Honeycomb Refinery.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.9+

## Installing the Chart

Create a Kubernetes secret to store your API Key

```shell
export HONEYCOMB_API_KEY=mykey
kubectl create secret generic honeycomb --from-literal=api-key=$HONEYCOMB_API_KEY
```

Add the Honeycomb Helm repository:

```shell
helm repo add honeycomb https://honeycombio.github.io/helm-charts
```

To install the chart with the release name `my-pipeline`, run the following command:

`helm install my-pipeline honeycomb/observability-pipeline`

To uninstall the chart:

`helm uninstall my-pipeline`
