# Honeycomb Network Agent

The Helm chart installs the [Honeycomb Network Agent](https://github.com/honeycombio/honeycomb-network-agent) in a Kubernetes cluster.

## TL;DR

```console
helm repo add honeycomb https://honeycombio.github.io/helm-charts
export HONEYCOMB_API_KEY=YOUR_API_KEY
helm install network-agent honeycomb/network-agent --set honeycomb.apiKey=$HONEYCOMB_API_KEY
```

## Prerequisites

- Helm 3.0+
- Kubernetes 1.24+
- Linux Kernel 5.10+ with NET_RAW capabilities

## Installing the Chart

### Setting a Honeycomb API Key

The easiest way to install the chart is by setting the Honeycomb API key directly:

```console
export HONEYCOMB_API_KEY=YOUR_API_KEY
helm install network-agent honeycomb/network-agent --set honeycomb.apiKey=$HONEYCOMB_API_KEY
```

**NOTE**: A secret to hold your Honeycomb API key is automatically created when the chart is installed and will be removed when the chart is uninstalled.

The best practice is to manage your secret separately. You can set the name of an existing secret that will be used instead of creating one:

```console
export HONEYCOMB_API_KEY=YOUR_API_KEY
kubectl create secret generic hny-secrets --from-literal=apiKey=$HONEYCOMB_API_KEY
helm install network-agent honeycomb/network-agent --set honeycomb.existingSecret=hny-secrets
```

The default key used to retrieve the API from the secret key is `apiKey`. You can provide an alternative key by setting the `existingSecretKey` value.

**NOTE**: If you use a separate secret key to manage your API keys, it is also recommened to set a custom pod annotation that can be used to trigger a redeployment of pods.

### Using a values.yaml

If you prefer to manage your helm charts by providing your own values.yaml, it is recommended to use an existing secret to avoid storing your Honeycomb API key as plain text.

```console
export HONEYCOMB_API_KEY=YOUR_API_KEY
kubectl create secret generic hny-secrets --from-literal=apiKey=$HONEYCOMB_API_KEY
helm install network-agent honeycomb/network-agent --values /path/to/values.yaml
```

## Configuration

The [values.yaml](./values.yaml) file contains information for all configuration options for this chart.

The only requirement is a Honeycomb API Key. This can be provided either by setting `honeycomb.apiKey` or by setting `honeycomb.existingSecret` to the name of an existing opaque secret resource.

You can obtain your API Key by going to your Account profile page inside of your Honeycomb instance.

## Deployment Privileges

The network agent requires the following permissions to enrich generated events with kubernetes metadata.

```yaml
  - apiGroups: [""]
    resources: ["nodes", "pods", "services"]
    verbs: ["get","watch","list"]
```
