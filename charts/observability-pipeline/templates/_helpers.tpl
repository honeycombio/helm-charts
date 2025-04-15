{{/*
Expand the name of the chart.
*/}}
{{- define "honeycomb-observability-pipeline.name" -}}
{{- default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "honeycomb-observability-pipeline.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "honeycomb-observability-pipeline.serviceName" -}}
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
{{- define "honeycomb-observability-pipeline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common beekeeper labels
*/}}
{{- define "honeycomb-observability-pipeline.beekeeper.labels" -}}
helm.sh/chart: {{ include "honeycomb-observability-pipeline.chart" . }}
{{ include "honeycomb-observability-pipeline.beekeeper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Beekeeper Selector labels
*/}}
{{- define "honeycomb-observability-pipeline.beekeeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "honeycomb-observability-pipeline.name" . }}-beekeeper
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use for beekeeper
*/}}
{{- define "honeycomb-observability-pipeline.beekeeper.serviceAccountName" -}}
{{- if .Values.beekeeper.serviceAccount.create }}
{{- default (printf "%s-beekeeper" (include "honeycomb-observability-pipeline.fullname" .)) .Values.beekeeper.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.beekeeper.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Build otel config file for beekeeper
*/}}
{{- define "honeycomb-observability-pipeline.beekeeperOTelConfig" -}}
{{- tpl (toYaml .Values.beekeeper.telemetry.config) . }}
{{- end }}

{{/*
Create ConfigMap checksum annotation for beekeeper
*/}}
{{- define "honeycomb-observability-pipeline.beekeeper.configTemplateChecksumAnnotation" -}}
  checksum/config: {{ include (print $.Template.BasePath "/beekeeper-configmap-otel.yaml") . | sha256sum }}
{{- end }}

{{/*
Build config file for collector
*/}}
{{- define "honeycomb-observability-pipeline.primaryCollector.config" -}}
server:
  endpoint: ws://{{ include "honeycomb-observability-pipeline.name" . }}-observability-pipeline-beekeeper:4320/v1/opamp
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
  executable: /otelcol-contrib
  config_apply_timeout: 10s
  description:
    identifying_attributes:
      service.name: {{ .Values.primaryCollector.serviceName }}
      service.namespace: htp.collector

storage:
  directory: /var/lib/otelcol/supervisor
{{ if .Values.primaryCollector.opampsupervisor.telemetry.enabled }}
telemetry:
  {{- tpl (toYaml .Values.primaryCollector.opampsupervisor.telemetry.config) . | nindent 2}}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for the collector
*/}}
{{- define "honeycomb-observability-pipeline.primaryCollector.serviceAccountName" -}}
{{- if .Values.primaryCollector.serviceAccount.create }}
{{- default (printf "%s-primary-collector" (include "honeycomb-observability-pipeline.fullname" .)) .Values.primaryCollector.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.primaryCollector.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common collector labels
*/}}
{{- define "honeycomb-observability-pipeline.primaryCollector.labels" -}}
helm.sh/chart: {{ include "honeycomb-observability-pipeline.chart" . }}
{{ include "honeycomb-observability-pipeline.primaryCollector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Collector Selector labels
*/}}
{{- define "honeycomb-observability-pipeline.primaryCollector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "honeycomb-observability-pipeline.name" . }}-primary-collector
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create ConfigMap checksum annotation for collector
*/}}
{{- define "honeycomb-observability-pipeline.primaryCollector.configTemplateChecksumAnnotation" -}}
  checksum/config: {{ include (print $.Template.BasePath "/primary-collector-configmap.yaml") . | sha256sum }}
{{- end }}

{{/*
Calculate beekeeper endpoint based on region
*/}}
{{- define "honeycomb-observability-pipeline.beekeeper.endpoint" -}}
{{- if eq .Values.global.region "production-eu" }}
{{- default "https://api.eu1.honeycomb.io" .Values.beekeeper.endpoint }}
{{- else }}
{{- default "https://api.honeycomb.io" .Values.beekeeper.endpoint }}
{{- end }}
{{- end }}

{{/*
Calculate TELEMETRY_ENDPOINT endpoint based on region
*/}}
{{- define "honeycomb-observability-pipeline.beekeeper.telemetryEndpoint" -}}
{{- if .Values.beekeeper.defaultEnv.TELEMETRY_ENDPOINT.content }}
{{ .Values.beekeeper.defaultEnv.TELEMETRY_ENDPOINT.content | toYaml }}
{{- else if eq .Values.global.region "production-eu" }}
value: https://api.eu1.honeycomb.io
{{- else }}
value: https://api.honeycomb.io
{{- end }}
{{- end }}

{{/*
Calculate primary collector opampsupervisor default endpoint for telemetry
*/}}
{{- define "honeycomb-observability-pipeline.primaryCollector.opampsupervisor.telemetry.defaultEndpoint" -}}
{{- if eq .Values.global.region "production-eu" }}
{{- default "https://api.eu1.honeycomb.io" .Values.primaryCollector.opampsupervisor.telemetry.defaultEndpoint }}
{{- else }}
{{- default "https://api.honeycomb.io" .Values.primaryCollector.opampsupervisor.telemetry.defaultEndpoint }}
{{- end }}
{{- end }}
