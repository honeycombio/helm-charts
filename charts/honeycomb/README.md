# Honeycomb Kubernetes Agent

[Honeycomb](https://honeycomb.io) is built for modern dev teams to see and understand how their production systems are 
behaving. Our goal is to give engineers the observability they need to eliminate toil and delight their users.
This helm chart will install the [Honeycomb Kubernetes Agent](https://github.com/honeycombio/honeycomb-kubernetes-agent).

## TL;DR;
```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install honeycomb honeycomb/honeycomb --set honeycomb.apiKey=YOUR_API_KEY
```

## Prerequisites
- Helm 3.0+

## Installing the Chart
### Using default agent configuration
By default, this chart will collect metrics from all nodes and pods, and watchers configuration to capture logs from the following system components:
- kube-controller-manager
- kube-scheduler
```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install honeycomb honeycomb/honeycomb --set honeycomb.apiKey=YOUR_API_KEY
```

### Using modified log watchers configuration
The agent watchers can be configured via this chart's `agent.watchers` property. Create a yaml file with your
Honeycomb API key and custom agent configuration similar to the following:
```yaml
honeycomb:
  apiKey: YOUR_API_KEY
watchers:
  - dataset: kubernetes-logs
    labelSelector: component=kube-controller-manager
    namespace: kube-system
    parser: glog
  - dataset: kubernetes-logs
    labelSelector: component=kube-scheduler
    namespace: kube-system
    parser: glog
```
Then use this yaml file when installing the chart
```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install honeycomb honeycomb/honeycomb --values my-values-file.yaml
```

### Capturing events with Heptio Eventrouter
An optional configuration is to capture Kubernetes events using the 
[Heptio Eventrouter](https://github.com/heptiolabs/eventrouter) component.
Configure the Eventrouter to use the `stdout` sink for logs, and you can capture them
with this watchers configuration  
```yaml
watchers:
  - dataset: k8s-eventrouter
    labelSelector: app=eventrouter
    namespace: olly
    parser: json
    processors:
      - drop_field:
          field: old_event
```

See [docs](https://github.com/honeycombio/honeycomb-kubernetes-agent/blob/master/docs/configuration-reference.md) for more information on agent watchers configuration.

## Configuration

The [values.yaml](./values.yaml) file contains information about all configuration
options for this chart.

The only requirement is a Honeycomb API Key. This can be provided either by setting `honeycomb.apiKey` or by setting `honeycomb.existingSecret` to the name of an existing opaque secret resource with your API Key specified in the `api-key` field. 

You can obtain your API Key by going to your Account profile page inside of your Honeycomb instance.

## Parameters

The following table lists the configurable parameters of the Honeycomb chart, and their default values.

| Parameter | Description | Default |
| --- | --- | --- |
| `honeycomb.apiKey` | Honeycomb API Key | `YOUR_API_KEY` |
| `honeycomb.apiHost` | API URL to sent events to | `https://api.honeycomb.io` |
| `honeycomb.existingSecret` | Name of an existing secret resource to use containing your API Key in the `api-key` field | `nil` |
| `watchers` | An array of `watchers` configuration snippets for the log agent ([docs](https://github.com/honeycombio/honeycomb-kubernetes-agent/blob/master/docs/configuration-reference.md)). Set this to an empty array `[]` to disable log collection. | kube-controller-manager, kube-scheduler |
| `verbosity` | Agent log level | `info` |
| `splitLogging` | Send all log levels to stdout instead of stderr | `false` |
| `additionalFields` | Additional fields to add to each event | `nil` |
| `metrics.enabled` | Enable and install metrics collection as events into Honeycomb | `true` |
| `metrics.dataset` | Name of Honeycomb dataset for Kubernetes metrics | `kubernetes-metrics` |
| `metrics.clusterName` | Name of Kubernetes cluster to use for metrics | `k8s-cluster` |
| `metrics.metricGroups` | Resource groups (node, pod, container, volume) to collect metrics from | `node, pod` |
| `metrics.omitLabels` | Pod labels to omit from being emitted as fields in metrics | `nil` |
| `metrics.additionalFields` | Additional fields to add to each metric (overrides global setting) | `nil` |
| `nameOverride` | String to partially override honeycomb.fullname template with a string (will append the release name) | `nil` |
| `fullnameOverride` | String to fully override honeycomb.fullname template with a string | `nil` |
| `imagePullSecrets` | Specify docker-registry secret names as an array | `[]` |
| `image.repository` | Honeycomb Agent Image name | `honeycombio/honeycomb-kubernetes-agent` |
| `image.tag` | Honeycomb Image tag (leave blank to use app version) | `nil` |
| `image.pullPolicy` | Honeycomb agent image pull policy | `IfNotPresent` |
| `terminationGracePeriodSeconds` | How many seconds to wait before terminating agent on shutdown | `30` |
| `podAnnotations` | Pod annotations | `{}` |
| `podSecurityContext` | Security context for pod | `{}` | 
| `securityContext` | Security context for container | `{}` | 
| `resources` | CPU/Memory resource requests/limits | `{}` | 
| `nodeSelector` | Node labels for pod assignment | `{}` | 
| `tolerations` | Tolerations for pod assignment | `[]`| 
| `affinity` | Map of node/pod affinities | `{}` |
| `rbac.create` | Specify whether RBAC resources should be created and used | `true` |
| `serviceAccount.create` | Specify whether a ServiceAccount should be created | `true` |
| `serviceAccount.name` | The name of the ServiceAccount to create | Generated using the `honeycomb.fullname` template |
| `serviceAccount.annotations` | Annotations to be applied to ServiceAccount | `{}` |


## Upgrading

### Upgrading from 0.11.0 or earlier

The `agent.` prefix for properties has been deprecated. 
All properties under this space have been moved to the root level. 
In a future release the `agent.` prefix will no longer work for any property.

The Metrics functionality has been completely revamped. No more dependencies on external
components (heapster). As such the default dataset has changed, and other properties
associated with metrics are updated.

The Events functionality has been removed in favor of using the Heptio event router.
