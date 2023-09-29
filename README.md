# Honeycomb Helm Charts

[![OSS Lifecycle](https://img.shields.io/osslifecycle/honeycombio/helm-charts?color=success)](https://github.com/honeycombio/home/blob/main/honeycomb-oss-lifecycle-and-practices.md)
[![CircleCI](https://circleci.com/gh/honeycombio/helm-charts.svg?style=shield)](https://circleci.com/gh/honeycombio/helm-charts)

[Helm](https://helm.sh/) is a package manager for Kubernetes.
You can use Helm for installing [Honeycomb](https://honeycomb.io) packages in your Kubernetes cluster.

Packages:
- [Honeycomb Kubernetes Agent](./charts/honeycomb)
- [Honeycomb Network Agent](./charts/network-agent)
- [Honeycomb Refinery](./charts/refinery)
- [OpenTelemetry-Collector](./charts/opentelemetry-collector)

## Installation

### Add the Honeycomb Repo
```
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm repo update
```
### Install a chart
Follow the steps within the packages listed above to install the relevant chart.
