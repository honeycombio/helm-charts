# Honeycomb Helm Charts

[![OSS Lifecycle](https://img.shields.io/osslifecycle/honeycombio/helm-charts?color=success)](https://github.com/honeycombio/home/blob/main/honeycomb-oss-lifecycle-and-practices.md)
[![CircleCI](https://circleci.com/gh/honeycombio/helm-charts.svg?style=shield)](https://circleci.com/gh/honeycombio/helm-charts)

[Helm](https://helm.sh/) is a package manager for Kubernetes.
You can use Helm for installing [Honeycomb](https://honeycomb.io) packages in your Kubernetes cluster.

Packages:
- [Honeycomb Kubernetes Agent](https://github.com/honeycombio/helm-charts/blob/main/charts/honeycomb)
- [Honeycomb Network Agent](https://github.com/honeycombio/helm-charts/blob/main/charts/network-agent)
- [Honeycomb Refinery](https://github.com/honeycombio/helm-charts/blob/main/charts/refinery)
- [Honeycomb Telemetry Pipeline](https://github.com/honeycombio/helm-charts/blob/main/charts/htp) (based on Bindplane)
- [OpenTelemetry-Collector](https://github.com/honeycombio/helm-charts/blob/main/charts/opentelemetry-collector)

## Installation

### Add the Honeycomb Repo
```
helm repo add honeycomb https://honeycombio.github.io/helm-charts
helm repo update
```
### Install a chart
Follow the steps within the packages listed above to install the relevant chart.
