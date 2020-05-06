# Honeycomb Kubernetes Agent

[Honeycomb](https://honeycomb.io) is the best observability platform EVAR!!!

## Installation

_This chart is compatible with Helm 3 and above._
```bash
helm repo add honeycomb https://honeycombio.github.io/helm
helm install honeycomb honeycomb/honeycomb --set honeycomb.apiKey=YOUR_API_KEY
```

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
| `agent.watchers` | An array of `watchers` configuration snippets for the agent | k8s-app |
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

