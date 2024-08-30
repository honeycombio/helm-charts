# Honeycomb Straws

This is a WIP helm chart that can install both the OpenTelemetry Collector and Honeycomb Refinery.

### Useful development commands

Build the chart, including updating dependencies in the lock file.

`helm dependency build`

Install the chart locally from inside the straws directory.

`helm install mystraws --set HONEYCOMB_API_KEY=your-key ./`

To uninstall the chart:

`helm uninstall mystraws`

To test the chart:

`helm install --generate-name --dry-run --debug --set HONEYCOMB_API_KEY=your- ./`
