# Refinery: Sampling Proxy Service for Honeycomb

[Refinery](https://github.com/honeycombio/refinery) is a trace-aware sampling proxy server for Honeycomb.

[Honeycomb](https://honeycomb.io) is built for modern software teams to see and understand how their production systems are behaving.
Our goal is to give engineers the observability they need to eliminate toil and delight their users.
This Helm Chart will install Refinery with the desired sampling rules passed in via a configuration file.

## TL;DR

```console
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install refinery honeycomb/refinery --set rules.SampleRate=2
```

## Prerequisites

- Helm 3.0+

## Installing the Chart

Add the Honeycomb repo to Helm:

```console
helm repo add honeycomb https://honeycombio.github.io/helm-charts
```

Install Refinery with your custom configuration file:

```console
helm install refinery honeycomb/refinery --values /path/to/your/refinery.yaml
```

If no configuration file is passed in, Refinery will deploy with the default configuration in [`values.yaml`](./values.yaml).

## Configuring sampling rules

### Deterministic Sampler

The default sampling method set in [`values.yaml`](./values.yaml) uses the `DeterministicSampler` with a `SampleRate` of 1.
This means that all of your data is sent to Honeycomb.
Refinery does not down-sample your data by default.

```yaml
# values.yaml
rules:
#  DryRun: false
  Sampler: DeterministicSampler
  SampleRate: 1
```

To configure custom sampling rules, you will need to pass in your own `refinery.yaml` file.
[The Refinery documentation](https://docs.honeycomb.io/manage-data-volume/refinery/sampling-methods/) goes into more detail about how each sampling method works.
These example configurations are provided to demonstrate how to define rules in YAML.

### Rules-Based Sampler

```yaml
# refinery.yaml
rules:
#  DryRun: false
  my_dataset:
    Sampler: "RulesBasedSampler"
    rule:
      - name: "keep 5xx errors"
        SampleRate: 1
        condition:
          field: "status_code"
          operator: ">="
          value: 500
      - name: "downsample 200 responses"
        SampleRate: 1000
        condition:
          field: "status_code"
          operator: "="
          value: 200
      - name: "send 1 in 10 traces"
        SampleRate: 10 # base case
```

### Exponential Moving Average (EMA) Dynamic Sampler

This is the recommended sampling method for most teams.

```yaml
# refinery.yaml
rules:
#  DryRun: false
  my_dataset:
    Sampler: "EMADynamicSampler"
    GoalSampleRate: 2
    FieldList:
      - "request.method"
      - "response.status_code"
    AdjustmentInterval: 15
    Weight: 0.5
```

## Configuration

The repository's [values.yaml](./values.yaml) file contains information about all configuration options for this chart.

### Refinery Metrics

If you decide to send [Refinery's runtime metrics](https://docs.honeycomb.io/manage-data-volume/refinery/scale-and-troubleshoot/#understanding-refinerys-metrics) to Honeycomb, you will need to give Refinery an API for the team you want those metrics sent to.

You can obtain your API Key by going to your Account profile page inside of your Honeycomb instance.

```yaml
# refinery.yaml
config:
  Metrics: honeycomb
  HoneycombMetrics:
    # MetricsHoneycombAPI: https://api.honeycomb.io # default
    MetricsAPIKey: YOUR_API_KEY
    # MetricsDataset: "Refinery Metrics" # default
    # MetricsReportingInterval: 3 # default
```

## Parameters

The following table lists the configurable parameters of the Refinery chart and their default values, as defined in [`values.yaml`](./values.yaml).

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of Refinery replicas | `2` |
| `image.repository` | Refinery image name | `honeycombio/refinery` |
| `image.pullPolicy` | Refinery image pull policy | `IfNotPresent` |
| `image.tag` | Refinery image tag (leave blank to use app version) | `nil` |
| `imagePullSecrets` | Specify docker-registry secret names as an array | `[]` |
| `nameOverride` | String to partially override refinery.fullname template with a string (will append the release name) | `nil` |
| `fullnameOverride` | String to fully override refinery.fullname template with a string | `nil` |
| `config` | Refinery core Configuration | see [Refinery Configuration](#configuration) |
| `rules` | Refinery sampling rules | see [Configuring sampling rules](#configuring-sampling-rules) |
| `redis.enabled` | When true, a Redis instance will be installed | `true` |
| `redis.existingHost` | If `redis.enabled` is false, this must be set to the name and port of an existing Redis service | `nil` |
| `redis.image.repository` | Redis image name | `redis` |
| `redis.image.tag` | Redis image tag | `6.0.2` |
| `redis.image.pullPolicy` | Redis image pull policy | `IfNotPresent` |
| `prometheus.serviceMonitor.create` | Creates service monitor to collect prom metrics (depends on kube-prom) | `false` |
| `serviceAccount.create` | Specify whether a ServiceAccount should be created | `true` |
| `serviceAccount.name` | The name of the ServiceAccount to create | Generated using the `refinery.fullname` template |
| `serviceAccount.annotations` | Annotations to be applied to ServiceAccount | `{}` |
| `podAnnotations` | Pod annotations | `{}` |
| `podSecurityContext` | Security context for pod | `{}` |
| `securityContext` | Security context for container | `{}` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.annotations` | Service annotations | `{}` |
| `ingress.enabled` | Enable ingress controller resource | `false` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts[0].name` | Hostname to your Refinery installation | `refinery.local` |
| `ingress.hosts[0].paths` | Path within the url structure | `[]` |
| `ingress.tls` | TLS hosts	| `[]` |
| `resources` | CPU/Memory resource requests/limits | limit: 1000m/2Gi, request: 500m/500Mi |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]`|
| `affinity` | Map of node/pod affinities | `{}` |
