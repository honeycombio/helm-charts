# Honeycomb Refinery

[Refinery](https://github.com/honeycombio/refinery) is a trace-aware sampling proxy server for Honeycomb.

[Honeycomb](https://honeycomb.io) is built for modern software teams to see and understand how their production systems are behaving.
Our goal is to give engineers the observability they need to eliminate toil and delight their users.
This Helm Chart will install Refinery with the desired sampling rules passed in via a configuration file.

## TL;DR

Install the chart with a deterministic sample rate of 1 out of every **2** traces.
```console
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install refinery honeycomb/refinery --set rules.Samplers.__default__.DeterministicSampler.SampleRate=2
```

## Prerequisites

- Helm 3.0+
- Kubernetes 1.23+

## Installing the Chart

Install Refinery with your custom chart values file

```console
helm install refinery honeycomb/refinery --values /path/to/refinery-values.yaml
```

If no configuration file is passed in, Refinery will deploy with the default configuration in [`values.yaml`](./values.yaml).

## Configuration

The repository's [values.yaml](./values.yaml) file contains information about all configuration options for this chart.
For details on Refinery-specific configuration review the [Refinery configuration docs](https://docs.honeycomb.io/manage-data-volume/refinery/configuration/).

**NOTE**: Configuration does not hot-reload and changes will recycle pods when upgrading via `helm upgrade` operations.

### Refinery Metrics

By default the chart exposes Refinery metrics via Prometheus, but if you decide to send [Refinery's runtime metrics](https://docs.honeycomb.io/manage-data-volume/refinery/scale-and-troubleshoot/#understanding-refinerys-metrics) to Honeycomb, you will need to give Refinery an API for the team you want those metrics sent to.

You can obtain your API Key by going to your Account profile page within your Honeycomb instance.

```yaml
# refinery.yaml
config:
  OTelMetrics:
    enabled: true
    # APIHost: https://api.honeycomb.io # default
    APIKey: YOUR_API_KEY
    # Dataset: "Refinery Metrics" # default
    # ReportingInterval: 30s # default
```

## Configuring sampling rules

Use [the Refinery documentation](https://docs.honeycomb.io/manage-data-volume/refinery/sampling-methods/) to learn how to configure your sampling rules.

**NOTE**: Sampling rules are hot-reloaded and do not require pods to restart to take effect when upgrading via `helm upgrade` operations.

### Disabling Live-Reload on Rules Changes

Depending on Kubernetes use-cases, operators may wish to disable Refinery's
default live-reload behavior on rules changes and rely instead on Kubernetes
to trigger a rolling pod update when the rule configmap changes.

This can be accomplished by setting

```yaml
LiveReload: false
```

## Redis Configuration

By default, a single node configuration of Redis will be installed. This configuration **is not** recommended for 
production deployments of Refinery. It is recommended that you configure and install a high available setup of Redis 
that can be used by this chart with the [`RedisPeerManagement` configuration option](A meaningful link) 

Redis is used for peer discovery only, and the workloads on an existing cluster will be minimal.

## Scaling Refinery

Refinery is a stateful service and is not optimized for dynamic auto-scaling. As such, we recommend provisioning refinery for your 
anticipated peak load.

The default configuration is to deploy 3 replicas with resource limits of 2 CPU cores, and 2Gi of memory. This configuration 
is capable to handle a modest sampling load and should be configured based on your expected peak load. Scaling requirements
are largely based on the velocity of spans received per second, and the average number of spans per trace. Other settings
such as rule complexity and trace duration timeouts will also have an effect on scaling requirements.

The primary setting that control scaling are `replicaCount` and `resources.limits`. Unless overriden, the value for
`resources.limits.memory` will be used for `config.Collection.AvailableMemory`.

See [Refinery: Scale and Troubleshoot](https://docs.honeycomb.io/manage-data-volume/refinery/scale-and-troubleshoot/)
for more details on how to properly scale Refinery.

### Using Autoscaling

Refinery can be configured to auto-scale with load. During auto-scale events, trace sharding is recomputed, which will
result in traces with missing spans being sent to Honeycomb. Traces with missing spans can happen for upto the 
`config.TraceTimeout * 2`. In order to avoid auto-scale events, it is recommended to disable scaleDown which will limit
broken traces should traffic rapidly go up and down.

Autoscaling of refinery is configured using the `autoscaling` setting.

## Parameters

The following table lists the configurable parameters of the Refinery chart, and their default values, as defined in [`values.yaml`](./values.yaml).

| Parameter | Description | Default |
| --- | --- | --- |
| `LiveReload` | If disabled, triggers a rolling restart of the cluster whenever the Rules configmap changes | `true` |
| `RulesConfigMapName` | Name of ConfigMap containing Refinery Rules | `""` |
| `affinity` | Map of node/pod affinities | `{}` |
| `autoscaling.behavior` | Set the autoscaling behavior | scaleDown.selectPolicy: disabled |
| `autoscaling.enabled` | Enabled autoscaling for Refinery | `false` |
| `autoscaling.maxReplicas` | Set maximum number of replicas for Refinery | `10` |
| `autoscaling.minReplicas` | Set minimum number of replicas for Refinery | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Set the target CPU utilization percentage for scaling | `75` | 
| `autoscaling.targetMemoryUtilizationPercentage` | Set the target Memory utilization percentage for scaling | `nil` |
| `config` | Refinery Configuration | see [Refinery Configuration](#configuration) |
| `fullnameOverride` | String to fully override refinery.fullname template with a string | `nil` |
| `grpcIngress.annotations` | gRPC Ingress annotations | `{}` |
| `grpcIngress.enabled` | Enable ingress controller resource for gRPC traffic | `false` |
| `grpcIngress.hosts[0].host` | Hostname to use for gRPC Ingress | `refinery.local` |
| `grpcIngress.hosts[0].path` | Path prefix that will be used for the host | `/` |
| `grpcIngress.labels` | gRPC Ingress labels | `{}` |
| `grpcIngress.tls` | TLS hosts	for gRPC Ingress | `[]` |
| `image.pullPolicy` | Refinery image pull policy | `IfNotPresent` |
| `image.repository` | Refinery image name | `honeycombio/refinery` |
| `image.tag` | Refinery image tag (leave blank to use app version) | `nil` |
| `imagePullSecrets` | Specify docker-registry secret names as an array | `[]` |
| `ingress.annotations` | HTTP Ingress annotations | `{}` |
| `ingress.enabled` | Enable Ingress controller resource for HTTP traffic | `false` |
| `ingress.hosts[0].host` | Hostname to use for HTTP Ingress | `refinery.local` |
| `ingress.hosts[0].path` | Path prefix that will be used for the host | `/` |
| `ingress.labels` | HTTP Ingress labels | `{}` |
| `ingress.tls` | TLS hosts for HTTP Ingress	| `[]` |
| `nameOverride` | String to partially override refinery.fullname template with a string (will append the release name) | `nil` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `podAnnotations` | Pod annotations | `{}` |
| `podLabels` | Pod labels | `{}` |
| `podSecurityContext` | Security context for pod | `{}` |
| `redis.affinity` | Map of node/pod affinities specific to the installed Redis deployment | `{}` |
| `redis.enabled` | When true, a Redis instance will be installed | `true` |
| `redis.image.pullPolicy` | Redis image pull policy | `IfNotPresent` |
| `redis.image.repository` | Redis image name | `redis` |
| `redis.image.tag` | Redis image tag | `6.0.2` |
| `redis.nodeSelector` | Node labels for pod assignment specific to the installed Redis deployment | `{}` |
| `redis.tolerations` | Tolerations for pod assignment specific to the installed Redis deployment | `[]`|
| `replicaCount` | Number of Refinery replicas | `3` |
| `resources` | CPU/Memory resource requests/limits | limit: 2000m/2Gi, request: 500m/500Mi |
| `rules` | Refinery sampling rules | see [Configuring sampling rules](#configuring-sampling-rules) |
| `secretProvider.create`<sup>1</sup> | Specify whether a SecretProvider should be created | `false` |
| `secretProvider.name` <sup>1</sup> | Specify the name of your SecretProvider | `nil` |
| `secretProvider.spec` <sup>1</sup> | Specify the spec of your SecretProvider | `nil` |
| `securityContext` | Security context for container | `{}` |
| `service.annotations` | Service annotations | `{}` |
| `service.grpcPort` | Service port for data in OTLP format over gRPC | `4317` |
| `service.labels` | Service labels | `{}` |
| `service.port` | Service port for data in Honeycomb format | `80` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `serviceAccount.annotations` | Annotations to be applied to ServiceAccount | `{}` |
| `serviceAccount.create` | Specify whether a ServiceAccount should be created | `true` |
| `serviceAccount.labels` | Labels to be applied to ServiceAccount | `{}` |
| `serviceAccount.name` | The name of the ServiceAccount to create | Generated using the `refinery.fullname` template |
| `tolerations` | Tolerations for pod assignment | `[]`|

1. secretProvider functionality requires the [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/)

## Upgrading

### Upgrading from 1.19.1 or earlier

[Refinery had a 2.0 release!](link to release notes).  It contains many important, but breaking, changes.  As a result, the chart
has also had a 2.0 release! All the breaking changes to the chart affect `config` and `rules`.  In order to help convert your existing values.yaml 
to the new 2.0 configuration options you can use the [Refinery Converter tool](https://github.com/honeycombio/refinery/tree/main/tools/convert). This tool is able to convert 
your existing values.yaml to the new 2.0 style, keeping all your custom configuration intact.

### Upgrading from 1.3.1 or earlier

`MaxBatchSize` is now configurable, set by default to its initially hardcoded value of 500. This value represents the number of events to include in a batch to be sent.

### Upgrading from 1.2.0 or earlier
`PeerManagement` defaults are being set, including `NetworkIdentifierName: eth0`. This was necessary
to ensure communications when DNS on K8s can be flaky at times (especially on startup). If you had set this before
you may need to update to use `eth0` instead as the value since the base image has also changed which controls this.

### Upgrading from 1.1.1 or earlier
The default limits and replica count and memory were increased to properly represent minimum production requirements. 
- `replicaCount` has been increased from `2` to `3`
- `resources.limits.memory` has been increased from `1Gi` to `2Gi`
- `config.TraceTimeout` has been decreased from `300s` to `60s`
