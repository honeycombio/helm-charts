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
{{- if and (ne .Values.global.customEndpoint "") (.Values.global.customEndpoint) }}
{{- default .Values.global.customEndpoint }}
{{- else if or (eq .Values.global.region "production-eu") (eq .Values.global.region "eu1") }}
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
{{- tpl (toYaml .Values.beekeeper.telemetry.config) . }}
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
  executable: /otelcol-contrib
  {{- if .Values.primaryCollector.agent.telemetry.enabled }}
  config_files: 
    - {{ .Values.primaryCollector.agent.telemetry.file }}
  {{- end }}
  passthrough_logs: true
  config_apply_timeout: {{ .Values.primaryCollector.agent.configApplyTimeout }}
  description:
    identifying_attributes:
      service.name: {{ .Values.primaryCollector.agent.telemetry.defaultServiceName }}
      service.namespace: htp.collector

storage:
  directory: /var/lib/otelcol/supervisor
{{ if .Values.primaryCollector.opampsupervisor.telemetry.enabled }}
telemetry:
  {{- tpl (toYaml .Values.primaryCollector.opampsupervisor.telemetry.config) . | nindent 2}}
{{- end }}
{{- end }}

{{/*
Build config file for collector
*/}}
{{- define "htp-builder.primaryCollector.agent.config" -}}
service:
  telemetry:
    {{- if .Values.primaryCollector.agent.telemetry.defaultServiceName }}
    resource:
      service.name: {{ .Values.primaryCollector.agent.telemetry.defaultServiceName }}
    {{- end }}
    {{- tpl (toYaml .Values.primaryCollector.agent.telemetry.config) . | nindent 4 }}
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
{{- default (include "htp-builder.apiBaseUrl" .) .Values.beekeeper.endpoint }}
{{- end }}

{{/*
Calculate primary collector opampsupervisor default endpoint for telemetry
*/}}
{{- define "htp-builder.primaryCollector.opampsupervisor.telemetry.defaultEndpoint" -}}
{{- default (include "htp-builder.apiBaseUrl" .) .Values.primaryCollector.opampsupervisor.telemetry.defaultEndpoint }}
{{- end }}

{{/*
Calculate primary collector agent default endpoint for telemetry
*/}}
{{- define "htp-builder.primaryCollector.agent.telemetry.defaultEndpoint" -}}
{{- default (include "htp-builder.apiBaseUrl" .) .Values.primaryCollector.agent.telemetry.defaultEndpoint }}
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
Get the name of the refinery service for primary-collector
*/}}
{{- define "htp-builder.refineryName" -}}
{{- if contains "refinery" .Release.Name }}
{{- print "refinery" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "refinery" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
