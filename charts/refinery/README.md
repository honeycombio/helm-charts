# Honeycomb Refinery

[Refinery](https://github.com/honeycombio/refinery) is a trace-aware sampling proxy server for Honeycomb.

[Honeycomb](https://honeycomb.io) is built for modern software teams to see and understand how their production systems are behaving.
Our goal is to give engineers the observability they need to eliminate toil and delight their users.
This Helm Chart will install Refinery with the desired sampling rules passed in via a configuration file.

## TL;DR

Install the chart with a deterministic sample rate of 1 out of every **2** events.
```console
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install refinery honeycomb/refinery --set rules.SampleRate=2
```

## Prerequisites

- Helm 3.0+

## Installing the Chart

Install Refinery with your custom chart values file

```console
helm install refinery honeycomb/refinery --values /path/to/refinery-values.yaml
```

If no configuration file is passed in, Refinery will deploy with the default configuration in [`values.yaml`](./values.yaml).

## Configuring sampling rules

The **Sample Rate** in Honeycomb is expressed as the denominator for 1 out of X events. 
A sample rate of 20 means to keep 1 event from every 20, which is also equivalent to a 5% sampling you may see with other platforms.

[The Refinery documentation](https://docs.honeycomb.io/manage-data-volume/refinery/sampling-methods/) goes into more detail about how each sampling method works.
These example configurations are provided to demonstrate how to define rules in YAML. See the complete definitions in the [sample-configs](./sample-configs) folder.

### Deterministic Sampler

The default sampling method uses the `DeterministicSampler` with a `SampleRate` of 1.
This means that all of your data is sent to Honeycomb.
Refinery does not down-sample your data by default.

```yaml
rules:
#  DryRun: false
  Sampler: DeterministicSampler
  SampleRate: 1
```

### Rules Based Sampler

The Rules Based Sampler allows you to specify specific span attribute values that will be used to determine a sample rate applied to the trace. 
Rules are evaluated in order as they appear in the configuration. 
A default rule should also be specified as the last rule.

```yaml
rules:
#  DryRun: false
  my_dataset:
    Sampler: "RulesBasedSampler"
    Rule:
      - Name: "keep 5xx errors"
        SampleRate: 1
        Condition:
          - Field: "status_code"
            Operator: ">="
            Value: 500
      - Name: "downsample 200 responses"
        SampleRate: 1000
        Condition:
          - Field: "http.status_code"
            Operator: "="
            Value: 200
      - Name: "send 1 in 10 traces"
        SampleRate: 10 # base case
```

### Exponential Moving Average (EMA) Dynamic Sampler

The EMA Dynamic Sampler, will determine sampling rates, based on field values. 
Values that are seen often (ie: http status 200) will get sampled less than values that are rare (ie: http status 500). 
You configure which fields to use for sampling decisions, the exponential moving average adjustment interval, and weight.
This is the recommended sampling method for most teams. 

```yaml
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
## Scaling Refinery

Refinery is a stateful service and is not optimized for dynamic auto-scaling. Changes in cluster membership can result
in temporary inconsistent sampling decisions and dropped traces. As such, we recommend provisioning refinery for your 
anticipated peak load.

The default configuration is to deploy 3 replicas with resource limits of 2 CPU cores, and 2Gi of memory. This configuration 
is capable to handle a modest sampling load and should be configured based on your expected peak load. Scaling requirements
are largely based on the velocity of spans received per second, and the average number of spans per trace. Other settings
such as rule complexity and trace duration timeouts will also have an effect on scaling requirements.

The primary setting that control scaling are `replicaCount` and `resources.limits`. When changing `resources.limits.memory`,
you must also change `config.InMemCollector.MaxAlloc`. This should be set to 75-90% of the available memory for each replica.
Refer to the comments in [values.yaml](./values.yaml) for more details about each property.

## Configuration

The repository's [values.yaml](./values.yaml) file contains information about all configuration options for this chart.

### Memory limits

Sampling traces is a memory intensive operation. To ensure Refinery properly manages the memory allocation you should
ensure the `config.InMemCollector.MaxAlloc` property is set in bytes to be 75%-90% of the pod memory limits configured
with the `resources.limits.memory` property.

### Refinery Metrics

If you decide to send [Refinery's runtime metrics](https://docs.honeycomb.io/manage-data-volume/refinery/scale-and-troubleshoot/#understanding-refinerys-metrics) to Honeycomb, you will need to give Refinery an API for the team you want those metrics sent to.

You can obtain your API Key by going to your Account profile page within your Honeycomb instance.

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
| `replicaCount` | Number of Refinery replicas | `3` |
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
| `serviceAccount.create` | Specify whether a ServiceAccount should be created | `true` |
| `serviceAccount.name` | The name of the ServiceAccount to create | Generated using the `refinery.fullname` template |
| `serviceAccount.annotations` | Annotations to be applied to ServiceAccount | `{}` |
| `podAnnotations` | Pod annotations | `{}` |
| `podSecurityContext` | Security context for pod | `{}` |
| `securityContext` | Security context for container | `{}` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port for data in Honeycomb format | `80` |
| `service.grpcPort` | Service port for data in OTLP format over gRPC | `4317` |
| `service.annotations` | Service annotations | `{}` |
| `ingress.enabled` | Enable ingress controller resource | `false` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts[0].name` | Hostname to your Refinery installation | `refinery.local` |
| `ingress.hosts[0].paths` | Path within the url structure | `[]` |
| `ingress.tls` | TLS hosts	| `[]` |
| `resources` | CPU/Memory resource requests/limits | limit: 2000m/2Gi, request: 500m/500Mi |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]`|
| `affinity` | Map of node/pod affinities | `{}` |
