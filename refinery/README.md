# Refinery: Sampling Proxy Service for Honeycomb

[Refinery](https://github.com/honeycombio/refinery) is a trace-aware sampling proxy server for Honeycomb.

[Honeycomb](https://honeycomb.io) is built for modern dev teams to see and understand how their production systems are behaving.
Our goal is to give engineers the observability they need to eliminate toil and delight their users.
This helm chart will install  with the desired sampling rules passed in via a configuration file.

## TL;DR

```console
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install refinery honeycomb/refinery --values /path/to/your/refinery.yaml
```

## Prerequisites

- Helm 3.0+

## Installing the Chart

```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install refinery honeycomb/refinery --values /path/to/your/refinery.yaml
```

## Configuring sampling rules

The default configuration set in [`values.yaml`](./values.yaml) uses the `DeterministicSampler` with a `SampleRate` of 1.
This means that all of your data is sent to Honeycomb.
Refinery does not down-sample your data by default.

```yaml
# Values used to build rules.yaml
rules:
#  DryRun: false
  Sampler: DeterministicSampler
  SampleRate: 1
```

To configure custom sampling rules, you will need to pass in your own `refinery.yaml` file.
The Refinery documentation goes into more detail about how each sampling method works.
These example configurations are provided to demonstrate the rules in YAML.

### Rules-Based Sampler

```yaml
rules:
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

### Exponential Moving Average Dynamic Sampler

This is the recommended sampler for most teams.

```yaml
rules:
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

## Parameters

The following table lists the configurable parameters of the Refinery chart and their default values.

`FIXME` how many of these are relevant?

| Parameter | Description | Default |
| --- | --- | --- |
| `honeycomb.apiKey` | Honeycomb API Key | `YOUR_API_KEY` |
| `honeycomb.apiHost` | API URL to sent events to | `https://api.honeycomb.io` |
| `honeycomb.dataset` | Name of dataset to send data into | `opentelemetry-collector` |
| `honeycomb.existingSecret` | Name of an existing secret resource to use containing your API Key in the `api-key` field | `nil` |
| `honeycomb.sample_rate` | Constant sample rate. Can be used to send 1 / x events to Honeycomb. Defaults to 1 (always sample) | `1` |
| `honeycomb.sample_rate_attribute` | The name of an attribute that contains the sample_rate for each span. | `nil` |
| `config` | OpenTelemetry Collector Configuration ([design docs](https://github.com/open-telemetry/opentelemetry-collector/blob/master/docs/design.md)) | receivers: [otlp, jaeger, zipkin] / processors: [memory_limiter, batch, queued_retry] / exporters: [honeycomb] |
| `nameOverride` | String to partially override opentelemetry-collector.fullname template with a string (will append the release name) | `nil` |
| `fullnameOverride` | String to fully override opentelemetry-collector.fullname template with a string | `nil` |
| `imagePullSecrets` | Specify docker-registry secret names as an array | `[]` |
| `image.repository` | OpenTelemetry Collector Image name | `otel/opentelemetry-collector-contrib` |
| `image.tag` | OpenTelemetry Collector Image tag (leave blank to use app version) | `nil` |
| `image.pullPolicy` | OpenTelemetry Collector image pull policy | `IfNotPresent` |
| `replicaCount` | Number of OpenTelemetry Collector nodes | `1` |
| `podAnnotations` | Pod annotations | `{}` |
| `podSecurityContext` | Security context for pod | `{}` |
| `securityContext` | Security context for container | `{}` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.annotations` | Annotations for OpenTelemetry Collector service | `{}` |
| `resources` | CPU/Memory resource requests/limits | limit: 1000m/2Gi, request: 200m/400Mi |
| `autoscaling.enabled` | Enable horizontal pod autoscaling | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas |  `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization | `nil` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]`|
| `affinity` | Map of node/pod affinities | `{}` |
| `serviceAccount.create` | Specify whether a ServiceAccount should be created | `true` |
| `serviceAccount.name` | The name of the ServiceAccount to create | Generated using the `honeycomb.fullname` template |
| `serviceAccount.annotations` | Annotations to be applied to ServiceAccount | `{}` |
| `k8sProcessor.rbac.create` | Specify whether the cluster-role and cluster-role-bindings should be created for the k8s_tagger processor | `false` |
| `k8sProcessor.rbac.name` | Name of the cluster-role and cluster-role-bindings for the k8s_tagger processor  | Generated using the `opentelemetry-collector.fullname` template `{opentelemetry-collector.fullname}-k8sprocessor` |
