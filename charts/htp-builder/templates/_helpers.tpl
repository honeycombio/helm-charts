{{/*
Expand the name of the chart.
*/}}
{{- define "htp-builder.name" -}}
{{- default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 
Get the api base URL
*/}}
{{- define "htp-builder.apiBaseUrl" -}}
{{- if and (ne .Values.region.customEndpoint "") (.Values.region.customEndpoint) }}
{{- default .Values.region.customEndpoint }}
{{- else if or (eq .Values.region.id "production-eu") (eq .Values.region.id "eu1") }}
{{- default "https://api.eu1.honeycomb.io"  }}
{{- else }}
{{- default "https://api.honeycomb.io" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "htp-builder.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "htp-builder.serviceName" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "htp-builder.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common beekeeper labels
*/}}
{{- define "htp-builder.beekeeper.labels" -}}
helm.sh/chart: {{ include "htp-builder.chart" . }}
{{ include "htp-builder.beekeeper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Beekeeper Selector labels
*/}}
{{- define "htp-builder.beekeeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "htp-builder.name" . }}-beekeeper
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use for beekeeper
*/}}
{{- define "htp-builder.beekeeper.serviceAccountName" -}}
{{- if .Values.beekeeper.serviceAccount.create }}
{{- default (printf "%s-beekeeper" (include "htp-builder.fullname" .)) .Values.beekeeper.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.beekeeper.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Build otel config file for beekeeper
*/}}
{{- define "htp-builder.beekeeperOTelConfig" -}}
{{- if .Values.beekeeper.telemetry.config }}
{{- tpl (toYaml .Values.beekeeper.telemetry.config) . }}
{{- else }}
file_format: "0.3"
propagator:
  composite:
    - tracecontext
    - baggage
tracer_provider:
  processors:
    - batch:
        exporter:
          otlp:
            protocol: http/protobuf
            endpoint: '{{ include "htp-builder.beekeeper.telemetryEndpoint" . }}'
            headers:
            - name: "x-honeycomb-team"
              value: ${HONEYCOMB_API_KEY}
meter_provider:
  readers:
    - periodic:
        exporter:
          otlp:
            protocol: http/protobuf
            endpoint: '{{ include "htp-builder.beekeeper.telemetryEndpoint" . }}'
            headers:
            - name: "x-honeycomb-team"
              value: ${HONEYCOMB_API_KEY}
            - name: "x-honeycomb-dataset"
              value: "beekeeper-metrics"
            temporality_preference: delta
logger_provider:
  processors:
    - batch:
        exporter:
          otlp:
            protocol: http/protobuf
            endpoint: '{{ include "htp-builder.beekeeper.telemetryEndpoint" . }}'
            headers:
            - name: "x-honeycomb-team"
              value: ${HONEYCOMB_API_KEY}
{{- end }}
{{- end }}

{{/*
Create ConfigMap checksum annotation for beekeeper
*/}}
{{- define "htp-builder.beekeeper.configTemplateChecksumAnnotation" -}}
  checksum/config: {{ include (print $.Template.BasePath "/beekeeper-configmap-otel.yaml") . | sha256sum }}
{{- end }}

{{/*
Build config file for opamp supervisor
*/}}
{{- define "htp-builder.primaryCollector.config" -}}
server:
  endpoint: ws://{{ include "htp-builder.beekeeperName" . }}:4320/v1/opamp
  tls:
    # Disable verification to test locally.
    # Don't do this in production.
    insecure_skip_verify: true
    # For more TLS settings see config/configtls.ClientConfig

capabilities:
  reports_effective_config: true
  reports_own_metrics: true
  reports_own_logs: true
  reports_own_traces: true
  reports_health: true
  accepts_remote_config: true
  reports_remote_config: true

agent:
  executable: /honeycomb-otelcol
  {{- if .Values.primaryCollector.agent.telemetry.enabled }}
  config_files: 
    - {{ .Values.primaryCollector.agent.telemetry.file }}
  {{- end }}
  passthrough_logs: true
  config_apply_timeout: {{ .Values.primaryCollector.agent.configApplyTimeout }}
  description:
    identifying_attributes:
      service.name: {{ .Values.primaryCollector.agent.telemetry.serviceName }}
      service.namespace: htp.collector

storage:
  directory: /var/lib/otelcol/supervisor
{{ if .Values.primaryCollector.opampsupervisor.telemetry.enabled }}
telemetry:
  {{- if .Values.primaryCollector.opampsupervisor.telemetry.config }}
    {{- tpl (toYaml .Values.primaryCollector.opampsupervisor.telemetry.config) . | nindent 2}}
  {{- else }}
  resource:
    service.name: {{ .Values.primaryCollector.opampsupervisor.telemetry.serviceName }}
  logs:
    level: info
    processors:
      - batch:
          exporter:
            otlp:
              protocol: http/protobuf
              endpoint: {{ include "htp-builder.primaryCollector.opampsupervisor.telemetryEndpoint" . }}
              headers:
              - name: x-honeycomb-team
                value: ${HONEYCOMB_API_KEY}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Build config file for collector
*/}}
{{- define "htp-builder.primaryCollector.agent.config" -}}
service:
  telemetry:
    {{- if .Values.primaryCollector.agent.telemetry.config }}
      {{- tpl (toYaml .Values.primaryCollector.agent.telemetry.config) . | nindent 4}}
    {{- else }}
    resource:
      service.name: {{ .Values.primaryCollector.agent.telemetry.serviceName }}
    metrics:
      readers:
        - periodic:
            exporter:
              otlp:
                endpoint: '{{ include "htp-builder.primaryCollector.agent.telemetryEndpoint" . }}'
                headers:
                  - name: x-honeycomb-dataset
                    value: primary-collector-metrics
                  - name: x-honeycomb-team
                    value: ${env:HONEYCOMB_API_KEY}
                protocol: http/protobuf
                temporality_preference: delta
    logs:
      encoding: json
      processors:
        - batch:
            exporter:
              otlp:
                endpoint: '{{ include "htp-builder.primaryCollector.agent.telemetryEndpoint" . }}'
                headers:
                  - name: x-honeycomb-team
                    value: ${env:HONEYCOMB_API_KEY}
                protocol: http/protobuf
    {{- end }}
{{- end }}

{{/*
Create the name of the service account to use for the collector
*/}}
{{- define "htp-builder.primaryCollector.serviceAccountName" -}}
{{- if .Values.primaryCollector.serviceAccount.create }}
{{- default (printf "%s-primary-collector" (include "htp-builder.fullname" .)) .Values.primaryCollector.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.primaryCollector.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common collector labels
*/}}
{{- define "htp-builder.primaryCollector.labels" -}}
helm.sh/chart: {{ include "htp-builder.chart" . }}
{{ include "htp-builder.primaryCollector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Collector Selector labels
*/}}
{{- define "htp-builder.primaryCollector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "htp-builder.name" . }}-primary-collector
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create ConfigMap checksum annotation for collector
*/}}
{{- define "htp-builder.primaryCollector.configTemplateChecksumAnnotation" -}}
  checksum/config: {{ include (print $.Template.BasePath "/primary-collector-configmap.yaml") . | sha256sum }}
{{- end }}

{{/*
Create ConfigMap checksum annotation for collector
*/}}
{{- define "htp-builder.primaryCollector.agent.configTemplateChecksumAnnotation" -}}
  checksum/agent-config: {{ include (print $.Template.BasePath "/primary-collector-agent-configmap.yaml") . | sha256sum }}
{{- end }}

{{/*
Calculate beekeeper endpoint based on region
*/}}
{{- define "htp-builder.beekeeper.endpoint" -}}
{{- default (include "htp-builder.apiBaseUrl" .) .Values.beekeeper.endpoint }}
{{- end }}

{{/*
Calculate Beekeeper telemetry endpoint based on region
*/}}
{{- define "htp-builder.beekeeper.telemetryEndpoint" -}}
{{- default (include "htp-builder.apiBaseUrl" .) (default .Values.telemetry.endpoint .Values.beekeeper.telemetry.endpoint) }}
{{- end }}

{{/*
Calculate primary collector opampsupervisor default endpoint for telemetry
*/}}
{{- define "htp-builder.primaryCollector.opampsupervisor.telemetryEndpoint" -}}
{{- default (include "htp-builder.apiBaseUrl" .) (default .Values.telemetry.endpoint .Values.primaryCollector.opampsupervisor.telemetry.endpoint) }}
{{- end }}

{{/*
Calculate primary collector agent default endpoint for telemetry
*/}}
{{- define "htp-builder.primaryCollector.agent.telemetryEndpoint" -}}
{{- default (include "htp-builder.apiBaseUrl" .) (default .Values.telemetry.endpoint .Values.primaryCollector.agent.telemetry.endpoint) }}
{{- end }}

{{/*
Get the name of the beekeeper service for refinery
*/}}
{{- define "htp-builder.beekeeperName" -}}
{{- if contains "htp-builder" .Release.Name }}
{{- printf "%s-%s" .Release.Name "beekeeper" | trunc 63 | trimSuffix "-"  }}
{{- else }}
{{- printf "%s-%s-%s" .Release.Name "htp-builder" "beekeeper" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common refinery labels
*/}}
{{- define "htp-builder.refinery.labels" -}}
helm.sh/chart: {{ include "htp-builder.chart" . }}
{{ include "htp-builder.refinery.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Refinery Selector labels
*/}}
{{- define "htp-builder.refinery.selectorLabels" -}}
app.kubernetes.io/name: {{ include "htp-builder.name" . }}-refinery
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Build config file for Refinery
*/}}
{{- define "htp-builder.refinery.config" -}}
{{- $config := deepCopy .Values.refinery.config }}
{{- if eq .Values.region.id "eu1" }}
{{- $config = mustMergeOverwrite (include "htp-builder.refinery.productionEU1Config" . | fromYaml) $config }}
{{- end }}
{{- if eq .Values.region.id "custom" }}
{{- $customEndpoint := (.Values.region.customEndpoint | trimSuffix "/") }}
{{- $config = mustMergeOverwrite (include "htp-builder.refinery.customConfig" (dict "customEndpoint" $customEndpoint "Values" .Values) | fromYaml) $config }}
{{- end }}
{{- tpl (toYaml $config) . }}
{{- end }}

{{/*
Build rules file for Refinery
*/}}
{{- define "htp-builder.refinery.rules" -}}
{{- $rules := deepCopy .Values.refinery.rules }}
{{- $default := get $rules.Samplers "__default__" }}
{{- if not $default }}
{{-   $_ := set $rules.Samplers "__default__" (include "htp-builder.refinery.defaultRules" . | fromYaml) }}
{{- end }} 
{{- tpl (toYaml $rules) . }}
{{- end }}

{{- define "htp-builder.refinery.defaultRules" -}}
DeterministicSampler:
  SampleRate: 1
{{- end}}

{{- define "htp-builder.refinery.productionEU1Config" -}}
Network:
  HoneycombAPI: https://api.eu1.honeycomb.io
HoneycombLogger:
  APIHost: {{ default "https://api.eu1.honeycomb.io" .Values.telemetry.endpoint }}
LegacyMetrics:
  APIHost: {{ default "https://api.eu1.honeycomb.io" .Values.telemetry.endpoint }}
OTelMetrics:
  APIHost: {{ default "https://api.eu1.honeycomb.io" .Values.telemetry.endpoint }}
OTelTracing:
  APIHost: {{ default "https://api.eu1.honeycomb.io" .Values.telemetry.endpoint }}
{{- end }}

{{- define "htp-builder.refinery.customConfig" -}}
Network:
  HoneycombAPI: {{ .customEndpoint }}
HoneycombLogger:
  APIHost: {{ default .customEndpoint .Values.telemetry.endpoint }}
LegacyMetrics:
  APIHost: {{ default .customEndpoint .Values.telemetry.endpoint }}
OTelMetrics:
  APIHost: {{ default .customEndpoint .Values.telemetry.endpoint }}
OTelTracing:
  APIHost: {{ default .customEndpoint .Values.telemetry.endpoint }}
{{- end }}

{{/*
Common refinery redis labels
*/}}
{{- define "htp-builder.refinery.redis.labels" -}}
helm.sh/chart: {{ include "htp-builder.chart" . }}
{{ include "htp-builder.refinery.redis.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Refinery Selector labels
*/}}
{{- define "htp-builder.refinery.redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "htp-builder.name" . }}-redis
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use for refinery
*/}}
{{- define "htp-builder.refinery.serviceAccountName" -}}
{{- if .Values.refinery.serviceAccount.create }}
{{- default (printf "%s-refinery" (include "htp-builder.fullname" .)) .Values.refinery.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.refinery.serviceAccount.name }}
{{- end }}
{{- end }}
