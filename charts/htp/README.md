# Honeycomb Telemetry Pipeline

This chart is [being sunset](https://github.com/honeycombio/home/blob/main/honeycomb-oss-lifecycle-and-practices.md#repository-states) and is replaced by the [`htp-bindplane` chart](../htp-bindplane). All new HTP - Bindplane users should use the [`htp-bindplane` chart](../htp-bindplane) instead.

If you're using HTP - Pipeline Builder, use the [`htp-builder` chart](../htp-builder).

Existing users of this chart, please switch to the [`htp-bindplane` chart](../htp-bindplane) instead. The `values.yaml` structure is the same, so no need to change your `values.yaml`, only the helm chart being installed.
