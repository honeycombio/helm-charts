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
By default this chart will deploy an agent watchers configuration to capture logs from the following system components:
- kube-controller-manager
- kube-scheduler

```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install honeycomb honeycomb/honeycomb --set honeycomb.apiKey=YOUR_API_KEY
```
### Using modified agent configuration
The agent watchers can be configured via this chart's `agent.watchers` property. Create a yaml file with your
Honeycomb API key and custom agent configuration similar to the following:
```yaml
honeycomb:
  apiKey: YOUR_API_KEY
agent:
  watchers:
    - dataset: kubernetes-logs
      labelSelector: component=kube-controller-manager
      namespace: kube-system
      parser: glog
    - <dataset: kubernetes-logs
      labelSelector: component=kube-scheduler
      namespace: kube-system
      parser: glog
```
Then use this yaml file when installing the chart
```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install honeycomb honeycomb/honeycomb --values my-values-file.yaml
```
See [docs](https://github.com/honeycombio/honeycomb-kubernetes-agent/blob/master/docs/configuration-reference.md) for more information on agent watchers configuration.

## Configuration

The [values.yaml](./values.yaml) file contains information about all configuration
options for this chart.

The only **required** option is `honeycomb.apiKey`. You can obtain your API Key by going to your Account profile 
page inside of your Honeycomb instance.

## Parameters

The following table lists the configurable parameters of the Honeycomb chart, and their default values.

| Parameter | Description | Default |
| --- | --- | --- |
| `honeycomb.apiKey` | Honeycomb API Key | `YOUR_API_KEY` |
| `honeycomb.apiHost` | API URL to sent events to | `https://api.honeycomb.io` |
| `agent.watchers` | An array of `watchers` configuration snippets for the agent ([docs](https://github.com/honeycombio/honeycomb-kubernetes-agent/blob/master/docs/configuration-reference.md)) | kube-controller-manager, kube-scheduler |
| `agent.verbosity` | Agent log level | `info` |
| `agent.splitLogging` | Send all log levels to stdout instead of stderr | `false` |
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
| `events.enabled` | Enable and install Kubernetes cluster events collection into Honeycomb (uses Heapster to collect events) | `true` |
| `events.dataset` | Name of Honeycomb dataset for cluster events | `kubernetes-cluster-events` | 
| `events.image.repository` | Heapster image name | `gcr.io/google_containers/heapster-amd64:v1.5.1` |
| `events.image.pullPolicy` | Heapster image pull policy | `IfNotPresent` |
| `events.podAnnotations` | Cluster events Pod annotations | `{}` |
| `events.podSecurityContext` | Cluster events Security context for pod | `{}` | 
| `events.securityContext` | Cluster events Security context for container | `{}` | 
| `events.resources` | Cluster events CPU/Memory resource requests/limits | `{}` | 
| `events.nodeSelector` | Cluster events Node labels for pod assignment | `{}` | 
| `events.tolerations` | Cluster events Tolerations for pod assignment | `[]`| 
| `events.affinity` | Cluster events Map of node/pod affinities | `{}` |
| `metrics.enabled` | Enable and install metrics collection as events into Honeycomb (uses Heapster to collect metrics) | `true` |
| `metrics.dataset` | Name of Honeycomb dataset for resource metrics | `kubernetes-resource-metrics` | 
| `metrics.image.repository` | Heapster image name | `gcr.io/google_containers/heapster-amd64:v1.5.1` |
| `metrics.image.pullPolicy` | Heapster image pull policy | `IfNotPresent` |
| `metrics.podAnnotations` | Metrics Pod annotations | `{}` |
| `metrics.podSecurityContext` | Metrics Security context for pod | `{}` | 
| `metrics.securityContext` | Metrics Security context for container | `{}` | 
| `metrics.resources` | Metrics CPU/Memory resource requests/limits | `{}` | 
| `metrics.nodeSelector` | Metrics Node labels for pod assignment | `{}` | 
| `metrics.tolerations` | Metrics Tolerations for pod assignment | `[]`| 
| `metrics.affinity` | Metrics Map of node/pod affinities | `{}` |
| `rbac.create` | Specify whether RBAC resources should be created and used | `true` |
| `serviceAccount.create` | Specify whether a ServiceAccount should be created | `true` |
| `serviceAccount.name` | The name of the ServiceAccount to create | Generated using the `honeycomb.fullname` template |
| `serviceAccount.annotations` | Annotations to be applied to ServiceAccount | `{}` |

## Issues with metrics
This chart will use the kubelet secured port by default to fetch resource metrics. On some Kubernetes platform like AKS,
you will need to use the non-secured kubelet port instead. 

Setting the `metrics.source` property to `kubernetes:https://kubernetes.default` will allow you to use the non-secured 
kubelet port for resource metrics.  