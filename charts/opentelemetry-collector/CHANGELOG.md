# OpenTelemetry Collector Helm Chart Changelog

## OpenTelemetry Collector v1.2.0

- Update OpenTelemetry Collector to 0.52.0 (#143)

## OpenTelemetry Collector v1.1.0

- Update OpenTelemetry Collector to v0.43.0 (#106)

## OpenTelemetry Collector v1.0.0

### Breaking Changes

- Support for legacy OTLP ports (55680 / 55681) has been removed from the OpenTelemetry Collector. You will need to update your SDKs to send to the new ports (4317 / 4318)

### Updates

- uses new memory_limiter processor and memory_ballast extensions (#68)

## OpenTelemetry Collector v0.4.3

- Exposes export options for default OTLP exporter. #50
- Adds option to use old Honeycomb exporter #51

## OpenTelemetry Collector v0.4.1

- Uses the proper protocol (UDP) for Jaeger thrift compact and binary #46 (@clly)

## OpenTelemetry Collector v0.4.0

- Uses the OTLP exporter instead of deprecated Honeycomb exporter #41
- Updates Collector to latest version 0.25.0

## OpenTelemetry Collector v0.3.2

- Updates Collector to latest version 0.23.0
- Adds support for configuration of all service ports #30 (@matoszz)
