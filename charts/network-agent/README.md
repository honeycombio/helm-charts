# Honeycomb Network Agent

The Helm chart install the [Honeycomb Network Agent](https://github.com/honeycombio/honeycomb-network-agent) in a Kubernetes cluster.

## TL;DR

```console
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install hny-network-agent honeycomb/network-agent --set honeycomb.apiKey=YOUR_API_KEY
```

## Prerequisites

- Helm 3.0+
- Kubernetes 1.24+
- Linux Kernel 5.10+ with NET_RAW capabilities

## Installing the Chart

### API Key

You easiest way to install the chart is by setting the API key directly:

```console
helm install hny-network-agent honeycomb/network-agent --set honeycomb.apiKey=YOUR_API_KEY
```

**NOTE**: A secret to hold your Honeycomb API key is automatically created for you when the chart is installed and will be removed when you uninstall the chart.

### Using an Existing Secret

If you prefer to manage your secrets separately, you can set the name of an existing secret that will be used instead of creating one:

```console
kubectl create secret generic hny-secrets --from-literal=apiKey=YOUR_API_KEY
helm install hny-network-agent honeycomb/network-agent --set honeycomb.existingSecret=hny-secrets
```

## Configuration

The [values.yaml](./values.yaml) file contains information for all configuration options for this chart.

The only requirement is a Honeycomb API Key. This can be provided either by setting `honeycomb.apiKey` or by setting `honeycomb.existingSecret` to the name of an existing opaque secret resource. 

You can obtain your API Key by going to your Account profile page inside of your Honeycomb instance.
