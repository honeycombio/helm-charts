# Honeycomb Secure Tenancy Proxy

[Honeycomb](https://honeycomb.io) is built for modern dev teams to see and understand how their production systems are 
behaving. Our goal is to give engineers the observability they need to eliminate toil and delight their users.
This helm chart will install the [Honeycomb Secure Tenancy Proxy](https://docs.honeycomb.io/authentication-and-security/secure-tenancy/).

## Prerequisites
- Helm 3.0+

## Preparing to install chart
### Enable Secure Tenancy in Honeycomb
Before installing this chart you will need to have Secure Tenancy enabled for your Honeycomb team. You will need to contact Honeycomb customer support or your account representative to have the functionality enabled.

### Building Image
Honeycomb will provide you with a tarball for Secure Tenancy. You will need to build the image using the provided [Dockerfile](./resources/Dockerfile). Copy the Secure Tenancy tarball into the same folder as the Dockerfile as `secure-tenancy.tbz` then run the following replacing YOUR_REPOSITORY accordingly:

```bash
docker build -t YOUR_REPOSITORY/honeycomb/secure-tenancy .
docker push YOUR_REPOSITORY/honeycomb/secure-tenancy
```

## Installing the chart
### Simple install (recommended for testing)
This will install the Secure Tenancy proxy, and a MySQL database using the Bitnami MariaDB chart.
A job to migrate and initialize the database will also be run as a post-install hook.
Since the job requires the MySQL database to be up and running, the Helm install command below may not return for upto 
3 minutes.
```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install secure-tenancy honeycomb/secure-tenancy \
    --set honeycomb.authToken=YOUR_SECURE_TENANCY_TOKEN \
    --set image.repository=YOUR_REPOSITORY/honeycomb/secure-tenancy
```

### Advanced install (recommended for production)
It's recommended to use a Helm values file to install this chart. The `honeycomb.authToken` and `image.repository` parameters are required. 
When used in a production environment a MySQL database is typically provided. 
You will need to set `mysql.enabled` to false, and `mysql.existingHost` to the host and port of the provided database.
All parameters, including those used for database credentials are described in the [Parameters](#parameters) section.
A typical installation values file may look like the following:
```yaml
honeycomb:
  authToken: YOUR_SECURE_TENANCY_TOKEN

image:
  repository: YOUR_REPOSITORY/honeycomb/secure-tenancy

metrics:
  apiKey: YOUR_API_KEY
  dataset: secure-tenancy-metrics

mysql:
  enabled: false
  existingHost: mysql.mysql:3306
  db:
    # MySQL user
    user: hny-secure-tenancy
    # MySQL password
    password: db_password
    # MySQL database
    name: hny-secure-tenancy
```

After the Helm values file is created, you can install the chart
```bash
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm install secure-tenancy honeycomb/secure-tenancy --values my-values.yaml
```

## Parameters

The following table lists the configurable parameters of the Honeycomb chart, and their default values.

| Parameter | Description | Default |
| --- | --- | --- |
| `honeycomb.authToken` | Honeycomb Secure Tenancy authorization token | `YOUR_AUTH_TOKEN` |
| `honeycomb.apiHost` | API URL to sent events to | `https://api.honeycomb.io` |
| `honeycomb.uiBaseUrl` | URL used to access Honeycomb UI | `https://ui.honeycomb.io` |
| `honeycomb.maxIdleConnsPerHost` | Maximum # of Idle connections to MySQL database | `100` |
| `honeycomb.hsts.enabled` | Wether or not to enable HTTP Strict Transport Security | `false` |
| `honeycomb.hsts.maxAge` | When HTST is enabled this is the max age in seconds | `31536000` |
| `honeycomb.transformer` | The Transformer to use for Secure Tenancy. Must be `aes256siv` or `sha256hmac` | `aes256siv` |
| `nameOverride` | String to partially override honeycomb.fullname template with a string (will append the release name) | `nil` |
| `fullnameOverride` | String to fully override honeycomb.fullname template with a string | `nil` |
| `imagePullSecrets` | Specify docker-registry secret names as an array | `[]` |
| `image.repository` | Honeycomb Secure Tenancy proxy repository and image name | `nil` |
| `image.tag` | Image tag to use (leave blank for latest) | `nil` |
| `image.pullPolicy` | Honeycomb agent image pull policy | `IfNotPresent` |
| `replicaCount` | Number of Secure Tenancy proxy server replicas to run | `2` |
| `metrics.apiKey` | Honeycomb API Key for Team to receive metrics about Secure Tenancy proxy | `YOUR_API_KEY` |
| `metrics.dataset` | Name of dataset to sent metrics to | `secure-tenancy` |
| `metrics.apiHost` | API URL to sent metrics to | `https://api.honeycomb.io` |
| `mysql.enabled` | When true the Bitnami MariaDB chart will be installed. | `true` |
| `mysql.existingHost` | If `mysql.enabled` is false, this must be set to the name and port of an existing MySQL database | `nil` |
| `mysql.tls` | Use TLS when communicating with MySQL | `false` |
| `mysql.maxopenconns` | Maximum open connections to MySQL | `100` |
| `mysql.db.user` | Name of MySQL user to connect as | `hny-secure-tenancy` |
| `mysql.db.password` | Password for database user | `db_password` |
| `mysql.db.name` | Name of MySQL database to connect | `hny-secure-tenancy` |
| `mysql.rootUser.password` | When `mysql.enabled` is true this will be the root password used | `root_password` |
| `mysql.replication.password` | When `mysql.enabled` is true this will be the replication password used | `replication_password` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port for Honeycomb formatted telemetry | `80` |
| `service.grpcPort` | Service port for OTLP over GRPC telemetry | `4317` |
| `service.ip` | LoadBalancer service IP address | `nil` |
| `service.annotations` | Service annotations | `{}` |
| `ingress.enabled` | Enable ingress controller resource | `false` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts[0].name` | Hostname to your Secure Tenancy installation | `secure-tenancy.local` |
| `ingress.hosts[0].paths` | Path within the url structure | `[]` |
| `ingress.tls` | TLS hosts	| `[]` |
| `autoscaling.enabled` | Enable autoscaling for Secure Tenancy deployment | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas to scale back (should be no less than 2) | `2` |
| `autoscaling.maxReplicas` | Maximum number of replicas to scale out | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target Memory utilization percentage | `80` |
| `podAnnotations` | Pod annotations | `{}` |
| `resources` | CPU/Memory resource requests/limits | `{}` | 
| `nodeSelector` | Node labels for pod assignment | `{}` | 
| `tolerations` | Tolerations for pod assignment | `[]`| 
| `affinity` | Map of node/pod affinities | `{}` |

## Template Manifest
It may be desired to have Helm render Kubernetes manifests but not have them installed.
You can use the `helm template` command to accomplish this. 
By default the output Kubernetes manifests will contain Helm specific annotations.
You can remove these from the output templates by setting a special `omitHelm` parameter to false when generating the templates.
