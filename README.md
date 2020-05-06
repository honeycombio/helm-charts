# Honeycomb Helm Charts

[Helm](https://helm.sh/) is a package manager for Kubernetes. 
You can use Helm for installing [Honeycomb](https://honeycomb.io) packages in your Kubernetes cluster.

Packages:
- [Honeycomb Kubernetes Agent](./honeycomb/)

## Installation

### Add the Honeycomb Repo
```
helm repo add honeycomb https://honeycombio.github.io/helm
helm repo update
```
### Install a chart
Follow the steps within the packages listed above to install the relevant chart.
