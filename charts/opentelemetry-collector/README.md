# Deprecation Notice

The OpenTelemetry Collector for Honeycomb helm chart is deprecated in favor of the [OpenTelemetry community's opentelemetry-collector helm chart](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector).
This community chart provides an overall better experience deploying and managing the collector in kubernetes.  

The primary difference between this chart and the community chart is that the community chart does not include a `honeycomb` section for specifying your API key, API host, and dataset name. Instead, you must configure an otlp/otlphttp exporter following [our Collector documentation](https://docs.honeycomb.io/getting-data-in/otel-collector/).  Example values.yaml for the OpenTelemetry community's opentelemetry-collector helm chart:

```yaml
mode: deployment

config:
  exporters:
    otlp:
      endpoint: "api.honeycomb.io:443"
      headers:
        "x-honeycomb-team": "YOUR_API_KEY"
        "x-honeycomb-dataset": "YOUR_DATASET_NAME"
  processors:
    pipelines:
      metrics:
        exporters: [otlp]
      traces:
        exporters: [otlp]
      logs:
        exporters: [otlp]
```

See https://github.com/honeycombio/helm-charts/issues/231 for more details.
