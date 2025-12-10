# Honeycomb Telemetry Pipeline Builder

> [!WARNING]  
> This is an experimental helm chart that is still under development. Breaking changes may be made without warning.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.9+

## Installing the Chart

Create a Kubernetes secret to store your API Key

```shell
export HONEYCOMB_PIPELINE_TELEMETRY_KEY=mypipelinetelemetrykey
export HONEYCOMB_MGMT_API_SECRET=mymanagementsecret
kubectl create secret generic htp-builder \
    --from-literal=pipeline-telemetry-key=$HONEYCOMB_PIPELINE_TELEMETRY_KEY \
    --from-literal=management-api-secret=$HONEYCOMB_MGMT_API_SECRET
```

Add the Honeycomb Helm repository:

```shell
helm repo add honeycomb https://honeycombio.github.io/helm-charts
```

To install the chart with the release name `my-pipeline`, run the following command:

```shell
helm install my-pipeline honeycomb/htp-builder \
    --set pipeline.id="pipeline-intallation-id" \
    --set managementApiKey.id="public-management-key-id"
```

To uninstall the chart:

```shell
helm uninstall my-pipeline`
```

### Honeycomb Ingest Keys

By default, Beekeeper will automatically create ingest keys and rotate them periodically. No additional configuration is required.

#### Using a Static Ingest Key

To use a static ingest key instead:

**Recommended: Using a Kubernetes Secret**

```shell
export HONEYCOMB_INGEST_KEY=myingestkey
export HONEYCOMB_PIPELINE_TELEMETRY_KEY=mypipelinetelemetrykey
export HONEYCOMB_MGMT_API_SECRET=mymanagementsecret
kubectl create secret generic htp-builder \
    --from-literal=pipeline-telemetry-key=$HONEYCOMB_PIPELINE_TELEMETRY_KEY \
    --from-literal=management-api-secret=$HONEYCOMB_MGMT_API_SECRET \
    --from-literal=ingest-key=$HONEYCOMB_INGEST_KEY

helm install my-pipeline honeycomb/htp-builder \
    --set pipeline.id="pipeline-intallation-id" \
    --set managementApiKey.id="public-management-key-id" \
    --set ingestKey.secret.name="htp-builder" \
    --set ingestKey.secret.key="ingest-key"
```

**Not Recommended: Direct Value**

```shell
export HONEYCOMB_INGEST_KEY=myingestkey
export HONEYCOMB_PIPELINE_TELEMETRY_KEY=mypipelinetelemetrykey
export HONEYCOMB_MGMT_API_SECRET=mymanagementsecret
kubectl create secret generic htp-builder \
    --from-literal=pipeline-telemetry-key=$HONEYCOMB_PIPELINE_TELEMETRY_KEY \
    --from-literal=management-api-secret=$HONEYCOMB_MGMT_API_SECRET

helm install my-pipeline honeycomb/htp-builder \
    --set pipeline.id="pipeline-intallation-id" \
    --set managementApiKey.id="public-management-key-id" \
    --set ingestKey.value=$HONEYCOMB_INGEST_KEY
```
