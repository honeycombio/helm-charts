# Refinery Helm Chart Changelog

## Refinery v1.18.0
  - maint: Update refinery chart to use refinery [1.20.0](https://github.com/honeycombio/refinery/releases/tag/v1.20.0) (#227) | @TylerHelmuth
    - This is a significant and exciting upgrade of Refinery.  For more details see [Refinery's Release notes](https://github.com/honeycombio/refinery/blob/main/RELEASE_NOTES.md#version-1200).
  - chore: add nodeport to the service.yaml (#222) | @fchikwekwe

## Refinery v1.17.0
  - fix: Updated ordering of CPU/Memory resource metrics (#217) | @robiball
  - maint: Update HPAs to autoscaling/v2 (#215) | @robiball
    - This means that the chart now only supports k8s 1.23+

## Refinery v1.16.0

- bump app version to 1.19.0 (#203) | [@TylerHelmuth](https://github.com/TylerHelmuth)
  - Add command to query config metadata
  - New cache management strategy

## Refinery v1.15.1

- Avoid checksum/config collision (#197) | @mterhar
- Update to set redis host based on release name (#194) | @TylerHelmuth

## Refinery v1.15.0

- Bump Refinery version to 1.18.0 (#188) | [@TylerHelmuth](https://github.com/TylerHelmuth)
  - Track span count and optionally add it to root
  - Add support for metrics api key env var
  - RedisIdentifier now operates properly in more circumstances
  - Properly set metadata to values that will work.

## Refinery v1.14.0

- Bump Refinery version to 1.17.0 (#182) | [@vreynolds](https://github.com/vreynolds)
  - Allow adding extra fields to error logs
  - Allow BatchTimeout to be overridden on the libhoney Transmission
  - Fix concurrent read/write

## Refinery v1.13.0

- Bump refinery version to 1.16.0 (#179) | [@kentquirk](https://github.com/kentquirk)
- Update sample config with new fields for new version (#178) | [@kentquirk](https://github.com/kentquirk)
- Add Helm namespace metadata (#175) | [@masonjlegere](https://github.com/masonjlegere)

## Refinery v1.12.1

- separate yaml layers to help parsing (#169) | [mterhar](https://github.com/mterhar)
- fix: Remove obsolete dash from configmap names (#170) | [bondarewicz](https://github.com/bondarewicz)

## Refinery v1.12.0

- Custom rules configmap (#162) | [@teaguecole](https://github.com/teaguecole)
- Use correct syntax in commented out field (#165) | [@jazzdan](https://github.com/jazzdan)
- Fix a TOML->YAML conversion whoopsie (#163) | [irvingpop](https://github.com/irvingpop)

## Refinery v1.11.0

- Enable extra volume configurations in deployment config (#147) | [@mars64](https://github.com/mars64)
- Bump Refinery to 1.15.0 (#153) | [@vreynolds](https://github.com/vreynolds)
  - Add scope-based rules

## Refinery v1.10.0

- Bump refinery to 1.14.1 (#139) | [@kentquirk](https://github.com/kentquirk)
  - Add support and sample config for environment and dataset rules with same names
  - Fix crash bug related to sharding

## Refinery v1.9.0

- bump app version to [1.13.0](https://github.com/honeycombio/refinery/releases/tag/v1.13.0) (#136) | [@JamieDanielson](https://github.com/JamieDanielson)
  - This release adds parsing for nested json fields in the rules sampler
- support ingressClassName (#105) | [@kentquirk](https://github.com/kentquirk)

## Refinery v1.8.0

- add readiness probe (#130) | [@MikeGoldsmith](https://github.com/MikeGoldsmith)
- bump app version to [1.12.1](https://github.com/honeycombio/refinery/releases/tag/v1.12.1) (#131) | [@vreynolds](https://github.com/vreynolds)
  - in this release: fix error log to match event metadata

## Refinery v1.7.0

- Bump app version to [v1.12.0](https://github.com/honeycombio/refinery/releases/tag/v1.12.0) (#125) | [@MikeGoldsmith](https://github.com/MikeGoldsmith)
  - this release adds preliminary support for environments and services

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
