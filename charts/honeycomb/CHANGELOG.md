# Honeycomb Kubernetes Agent Helm Chart Changelog

## Honeycomb Kubernetes Agent v1.8.0
 - feat: Added support for additional env variable settings (#242)

## Honeycomb Kubernetes Agent v1.7.1
 - maint: bump honeycomb chart appVersion (#238) | @TylerHelmuth

## Honeycomb Kubernetes Agent v1.7.0

- Bump kubernetes agent version to [2.7.0](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.7.0) (#226) | @TylerHelmuth
  - fix: Validate label selector and paths are mutually exclusive
  - fix: do not accumulate if pod is not there anymore
  - docs: Update keyval docs
  - docs: Add paths and exclude docs
  - maint(deps): bump k8s.io/kubelet from 0.26.1 to 0.26.2
  - maint(deps): bump k8s.io/client-go from 0.26.1 to 0.26.2
  - maint(deps): bump github.com/honeycombio/dynsampler-go
  - maint(deps): bump golang.org/x/net from 0.5.0 to 0.7.0
  - maint(deps): bump github.com/stretchr/testify from 1.8.1 to 1.8.2
  - maint(deps): bump k8s.io/client-go from 0.25.2 to 0.26.1
  - maint(deps): bump k8s.io/kubelet from 0.25.3 to 0.26.1
  - maint(deps): bump github.com/bmatcuk/doublestar/v4 from 4.3.0 to 4.6.0
  - Bump github.com/honeycombio/honeytail from 1.8.1 to 1.8.2
  - maint: don't spam the logs with filtered-out filenames
- docs: [honeycomb] - specify metric interval as duration unit (#221) | @puckpuck

## Honeycomb Kubernetes Agent v1.6.0

- Bump kubernetes agent version to [2.6.0](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.6.0) (#309)
    - Allow MinEventsPerSecond to be configured

## Honeycomb Kubernetes Agent v1.5.5

- Bump kubernetes agent version to [2.5.6](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.5.6) (#205)
    - Add support for building sample keys from integer fields

## Honeycomb Kubernetes Agent v1.5.4

- Bump kubernetes agent version to [2.5.5](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.5.5) (#148)
    - Put the k8s metadata processor first
    - Bump dependencies

## Honeycomb Kubernetes Agent v1.5.3

- Bump kubernetes agent version to [2.5.4](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.5.4) (#148)
  - Bump dependencies, including libhoney

## Honeycomb Kubernetes Agent v1.5.2

- Add helm namespace to templates (#155) | @alex-bezek
- Bump kubernetes agent version to [2.5.3](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.5.3) (#159)
  - fixed openSSL CVE

## Honeycomb Kubernetes Agent v1.5.1

- Bump kubernetes agent version to [2.5.2](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.5.2) (#148)
  - Update to Go 1.18
  - Only return cpu.utilization if a limit was provided

## Honeycomb Kubernetes Agent v1.5.0

- Bump agent version to [2.5.0](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.5.0) (#133)
  - Adds exclude capability for certain logging paths
  - Updates memory.utilization memory counter to use memory.workingset

## Honeycomb Kubernetes Agent v1.4.0

- Adds support for a retry ring buffer (#127)

## Honeycomb Kubernetes Agent v1.3.1

- Bump honeycomb agent from 2.3.1 to [2.3.2](https://github.com/honeycombio/honeycomb-kubernetes-agent/releases/tag/v2.3.2) (#113)
  - maintenance release updating libhoney-go
- docs: how to ingress local refinery chart (#112)

## Honeycomb Kubernetes Agent v1.3.0

- bump agent version to 2.3.1 (#98)
- add nodes resource to honeycomb/templates/cluster-role (#96)
- add pod labels to honeycomb kubernetes agent chart (#91)

## Honeycomb Kubernetes Agent v1.2.0

- Adds node metadata to metrics events
- Fixes intermittent exception in metrics processor

## Honeycomb Kubernetes Agent v1.1.1

- Fixes selectors for container metadata and logs

## Honeycomb Kubernetes Agent v1.1.0

- Adds support for multiple architectures (amd64 + arm64) #64

## Honeycomb Kubernetes Agent v1.0.4

- Adds support for priorityClassName to agent daemonset (#58)

## Honeycomb Kubernetes Agent v1.0.3

- Adds a NODE_IP configuration option for metics collection #28
