# Refinery Helm Chart Changelog

## Refinery v1.6.0

- bump app version to [1.10.0](https://github.com/honeycombio/refinery/releases/tag/v1.10.0) (#117) | [@vreynolds](https://github.com/vreynolds)
  - this release includes bug fixes and a new Redis Username configuration option

## Refinery v1.5.0

- Allow operators to disable live reload of Refinery related to changed sampling rules (#104)  | [@bixu](https://github.com/bixu)
- Bump refinery image version to [1.9.0](https://github.com/honeycombio/refinery/releases/tag/v1.9.0) (#111) | [@MikeGoldsmith](https://github.com/MikeGoldsmith)
  - Honor env. variable to set gRPC listener address
  - Add retries when connecting to redis during init
  - Properly set meta.refinery.local_hostname field

## Refinery v1.4.0

- Upgrade Refinery to v1.8.0, for configurable MaxBatchSize (#87) | [@JamieDanielson](https://github.com/JamieDanielson)
  - Refinery v1.7.0 also added improved histogram buckets for prometheus metrics
- Update docs on pod recycling for config changes (#86) | [@MikeGoldsmith](https://github.com/MikeGoldsmith)
- Add changelogs and update releasing process (#81) | [@JamieDanielson](https://github.com/JamieDanielson)

## Refinery v1.3.1

- Add release process by @puckpuck in #76
- Upgrade to Refinery 1.6.1 by @JamieDanielson in #77

## Refinery v1.3.0

- Adds support for HPA #71
- Adds support for an additional ingress to control gRPC traffic #72
- Enables PeerManagement defaults #73

## Refinery v1.2.0

- Update ingress controller specifications for K8s >= 1.19 #63
- Update default Redis deployment version to 6.2.5 #69
- Add support for additional labels on all resources #70 (@sbeginCoveo)
- Update Refinery to 1.5.0 which includes support for downstream samplers within a Rules-based sampler

## Refinery v1.1.2

- Adds support for pod scheduling to the optional Redis deployment (#59)

## Refinery v1.1.1

- Updates to refinery v1.4.0 including support for OTLP over HTTP (#53)

## Refinery v1.1.0

- Enables port 4317 for OTLP ingest #39
- Adjusts limits for production usage #40
- Fixes Redis service port name and issues with Istio #42

## Refinery v1.0.0

- All configuration and samples rules can be embedded at chart values
- Optional pre-packaged Redis distribution for peer management
