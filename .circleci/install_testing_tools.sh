#!/usr/bin/env bash

set -o errexit

readonly HELM_VERSION=3.5.2
readonly CHART_RELEASER_VERSION=1.2.0
readonly CHART_TESTING_VERSION=3.7.1
readonly MINIKUBE_VERSION=v1.27.1

echo "Installing Helm..."
curl -LO "https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz"
sudo mkdir -p "/usr/local/helm-v$HELM_VERSION"
sudo tar -xzf "helm-v$HELM_VERSION-linux-amd64.tar.gz" -C "/usr/local/helm-v$HELM_VERSION"
sudo ln -s "/usr/local/helm-v$HELM_VERSION/linux-amd64/helm" /usr/local/bin/helm
rm -f "helm-v$HELM_VERSION-linux-amd64.tar.gz"

echo "Installing Chart Testing..."
curl -LO "https://github.com/helm/chart-testing/releases/download/v$CHART_TESTING_VERSION/chart-testing_${CHART_TESTING_VERSION}_linux_amd64.tar.gz"
sudo mkdir -p "/usr/local/chart-testing-v$CHART_TESTING_VERSION"
sudo tar -xzf "chart-testing_${CHART_TESTING_VERSION}_linux_amd64.tar.gz" -C "/usr/local/chart-testing-v$CHART_TESTING_VERSION"
sudo ln -s "/usr/local/chart-testing-v$CHART_TESTING_VERSION/ct" /usr/local/bin/ct
rm -f "chart-testing_${CHART_TESTING_VERSION}_linux_amd64.tar.gz"

echo "Installing Kubectl..."
curl -Lo kubectl "https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "Installing Minikube..."
curl -Lo minikube "https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/minikube-linux-amd64"
chmod +x minikube
sudo mv minikube /usr/local/bin/
sudo apt-get install conntrack
