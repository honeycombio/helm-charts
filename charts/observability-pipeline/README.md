# Honeycomb Observability Pipeline

> [!WARNING]  
> This is an experimental helm chart that is still under development. Breaking changes may be made without warning.

This is a WIP helm chart that can install both the OpenTelemetry Collector and Honeycomb Refinery.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.9+

## Installing the Chart

Create a Kubernetes secret to store your API Key

```shell
export HONEYCOMB_API_KEY=mykey
export HONEYCOMB_MGMT_API_SECRET=mymanagementkey
kubectl create secret generic honeycomb-observability-pipeline --from-literal=api-key=$HONEYCOMB_API_KEY --from-literal=management-api-secret=$HONEYCOMB_MGMT_API_SECRET
```

Add the Honeycomb Helm repository:

```shell
helm repo add honeycomb https://honeycombio.github.io/helm-charts
```

To install the chart with the release name `my-pipeline`, run the following command:

`helm install my-pipeline honeycomb/observability-pipeline`

To uninstall the chart:

`helm uninstall my-pipeline`
