#!/usr/bin/env bash

set -o errexit

readonly HELM_VERSION=3.5.2
readonly CHART_RELEASER_VERSION=1.2.0

echo "Installing Helm..."
curl -LO "https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz"
sudo mkdir -p "/usr/local/helm-v$HELM_VERSION"
sudo tar -xzf "helm-v$HELM_VERSION-linux-amd64.tar.gz" -C "/usr/local/helm-v$HELM_VERSION"
sudo ln -s "/usr/local/helm-v$HELM_VERSION/linux-amd64/helm" /usr/local/bin/helm
rm -f "helm-v$HELM_VERSION-linux-amd64.tar.gz"

# setup chart dependency repositories here
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami


echo "Installing chart-releaser..."
curl -LO "https://github.com/helm/chart-releaser/releases/download/v${CHART_RELEASER_VERSION}/chart-releaser_${CHART_RELEASER_VERSION}_linux_amd64.tar.gz"
sudo mkdir -p "/usr/local/chart-releaser-v$CHART_RELEASER_VERSION"
sudo tar -xzf "chart-releaser_${CHART_RELEASER_VERSION}_linux_amd64.tar.gz" -C "/usr/local/chart-releaser-v$CHART_RELEASER_VERSION"
sudo ln -s "/usr/local/chart-releaser-v$CHART_RELEASER_VERSION/cr" /usr/local/bin/cr
rm -f "chart-releaser_${CHART_RELEASER_VERSION}_linux_amd64.tar.gz"
