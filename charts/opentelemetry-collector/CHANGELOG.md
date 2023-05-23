# OpenTelemetry Collector Helm Chart Changelog

## OpenTelemetry Collector v1.3.1

- deprecate opentelemetry-collector chart (#251) | [TylerHelmuth](https://github.com/TylerHelmuth)

## OpenTelemetry Collector v1.3.0

 - fix: Updated ordering of CPU/Memory resource metrics (#217) | @robiball
 - maint: Update HPAs to autoscaling/v2 (#215) | @robiball
    - This means that the chart now only supports k8s 1.23+
 - ci: Add collector test scenarios (#196) | @TylerHelmuth
 - ci: Add chart testing (#193) | @TylerHelmuth
 

## OpenTelemetry Collector v1.2.1

- Swap order of hpa spec.metrics #164 (@chrisdotm)

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
