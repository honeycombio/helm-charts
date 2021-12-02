# Honeycomb Helm Charts

[![OSS Lifecycle](https://img.shields.io/osslifecycle/honeycombio/helm-charts?color=success)](https://github.com/honeycombio/home/blob/main/honeycomb-oss-lifecycle-and-practices.md)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/honeycomb)](https://artifacthub.io/packages/search?repo=honeycomb)

[Helm](https://helm.sh/) is a package manager for Kubernetes.
You can use Helm for installing [Honeycomb](https://honeycomb.io) packages in your Kubernetes cluster.

Packages:
- [Honeycomb Kubernetes Agent](https://github.com/honeycombio/helm-charts/blob/main/charts/honeycomb)
- [Honeycomb Refinery](https://github.com/honeycombio/helm-charts/blob/main/charts/refinery)
- [Honeycomb Secure Tenancy Proxy](https://github.com/honeycombio/helm-charts/blob/main/charts/secure-tenancy)
- [OpenTelemetry-Collector](https://github.com/honeycombio/helm-charts/blob/main/charts/opentelemetry-collector)

## Installation

### Add the Honeycomb Repo
```
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm repo update
```
### Install a chart
Follow the steps within the packages listed above to install the relevant chart.
