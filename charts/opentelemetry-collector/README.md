# OpenTelemetry Collector for Honeycomb

[OpenTelemetry](https://opentelemetry.io) provides a single set of APIs, libraries, agents, and collector services to 
capture distributed traces and metrics from your application. 
[Honeycomb](https://honeycomb.io) is built for modern dev teams to see and understand how their production systems are 
behaving. Our goal is to give engineers the observability they need to eliminate toil and delight their users.
This helm chart will install the [OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector-contrib) 
with the OTLP exporter configured to send data to Honeycomb.

## TL;DR;
```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install opentelemetry-collector honeycomb/opentelemetry-collector --set honeycomb.apiKey=YOUR_API_KEY
```

## Prerequisites
- Helm 3.0+

## Installing the Chart
### Using default configuration
By default this chart will deploy an OpenTelemetry Collector as a single replica. A single pipeline will be configured 
for traces as follows:
```yaml
    receivers: [otlp, jaeger, zipkin]
    processors: [memory_limiter, batch]
    exporters: [otlp]
```

```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install opentelemetry-collector honeycomb/opentelemetry-collector --set honeycomb.apiKey=YOUR_API_KEY
```

### Specifying Honeycomb dataset name
If not specified this chart will be configured to send all data to a dataset named `opentelemetry-collector`. 
If you need to use a different dataset you can specify it using the `honeycomb.dataset` property.
```bash
helm install opentelemetry-collector honeycomb/opentelemetry-collector \
    --set honeycomb.apiKey=YOUR_API_KEY \
    --set honeycomb.dataset=YOUR_DATASET_NAME
```

### Using modified collector configuration
The collector's configuration can be overridden via this chart's `config` property. You only need to specify properties 
that you want to override. Make sure to override the `service` section if you want to add or remove receivers, processors, 
or exporters. Create a yaml file with your Honeycomb API key and custom collector configuration. This example will add a 
Jaeger exporter to the configuration.
```yaml
honeycomb:
  apiKey: YOUR_API_KEY
config:
  exporters:
    jaeger:
      endpoint: jaeger-collector:14250
      insecure: true
  service:
    pipelines:
      traces:
        exporters: [otlp, jaeger]
```
Then use this yaml file when installing the chart
```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install opentelemetry-collector honeycomb/opentelemetry-collector --values my-values-file.yaml
```
See [design docs](https://github.com/open-telemetry/opentelemetry-collector/blob/master/docs/design.md) for more 
information on the OpenTelemetry Collector configuration.

## Configuration

The [values.yaml](./values.yaml) file contains information about all configuration
options for this chart.

The only requirement is a Honeycomb API Key. This can be provided either by setting `honeycomb.apiKey` or by setting 
`honeycomb.existingSecret` to the name of an existing opaque secret resource with your API Key specified in the `api-key` 
field. 

You can obtain your API Key by going to your Account profile page inside of your Honeycomb instance.

## Parameters

The following table lists the configurable parameters of the Honeycomb chart, and their default values.

| Parameter | Description | Default |
| --- | --- | --- |
| `honeycomb.apiKey` | Honeycomb API Key | `YOUR_API_KEY` |
| `honeycomb.apiHost` | API URL to sent events to. This is the Honeycomb OTLP over gRPC endpoint. | `api.honeycomb.io:443` |
| `honeycomb.dataset` | Name of dataset to send data into | `opentelemetry-collector` |
| `honeycomb.existingSecret` | Name of an existing secret resource to use containing your API Key in the `api-key` field | `nil` |
| `honeycomb.exportOptions` | Configuration options for the OpenTelemetry [OTLP exporter](https://github.com/open-telemetry/opentelemetry-collector/blob/main/config/configgrpc/README.md) used to export data into Honeycomb. All options but `endpoint` and `headers` can be used. | `nil` |
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


## Upgrading

### Upgrading from 0.4.3 or earlier
OpenTelemetry has deprecated and removed the legacy ports for OTLP: 55680/55681. These ports have been removed from the 
default configuration. The proper default ports for OTLP are 4317 for OTLP/GRPC and 4318 for OTLP/HTTP.

Memory limiter and memory ballast have been reconfigured as part of the collector. A new processor and extension are now 
used to configure memory limits and ballast. The default settings, will respond dynamically to the configured pod memory
limits, and in most cases should not require any further configuration changes.

### Upgrading from 0.3.2 or earlier
The Honeycomb exporter has been deprecated in favor of using the OTLP exporter that the Honeycomb service supports natively. 
Since the default OTLP exporter is now used, sampling of data on export is no longer supported, and use of the 
`honeycomb.sample_rate` and `honeycomb.sample_rate_attribute` properties is no longer supported. 
Sampling can be accomplished using the [Probabilistic Sampling Processor](https://github.com/open-telemetry/opentelemetry-collector/tree/main/processor/probabilisticsamplerprocessor).
Advanced sampling techniques can be accomplished using the [Honeycomb Refinery](../refinery) Helm chart.

The default value for the `honeycomb.apiHost` property has changed to represent a gRPC endpoint address. 
If you copied this default value into your local values file, you will need to update this to `api.honeycomb.io:443` when upgrading.

### Upgrading from 0.1.1 or earlier
A breaking change in the OTLP receiver configuration was introduced. This change is part of the default configuration. 
If you changed the default OTLP receiver configuration, you will need to ensure your changes are compatible with the 
updated configuration layout for OTLP.
