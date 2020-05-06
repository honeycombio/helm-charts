{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "honeycomb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "honeycomb.fullname" -}}
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
{{- define "honeycomb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a name for Honeycomb agent
*/}}
{{- define "honeycomb.agent.fullname" -}}
{{- printf "%s-agent" (include "honeycomb.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a name for events collector
*/}}
{{- define "honeycomb.events.fullname" -}}
{{- printf "%s-events" (include "honeycomb.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a name for metrics collector
*/}}
{{- define "honeycomb.metrics.fullname" -}}
{{- printf "%s-metrics" (include "honeycomb.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Basic labels
*/}}
{{- define "honeycomb.basicLabels" -}}
helm.sh/chart: {{ include "honeycomb.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "honeycomb.labels" -}}
{{ include "honeycomb.basicLabels" . }}
{{ include "honeycomb.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "honeycomb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "honeycomb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Agent Common labels
*/}}
{{- define "honeycomb.agent.labels" -}}
{{ include "honeycomb.basicLabels" . }}
{{ include "honeycomb.agent.selectorLabels" . }}
{{- end }}

{{/*
Agent Selector labels
*/}}
{{- define "honeycomb.agent.selectorLabels" -}}
{{ include "honeycomb.selectorLabels" . }}
app.kubernetes.io/component: agent
{{- end }}

{{/*
Events Common labels
*/}}
{{- define "honeycomb.events.labels" -}}
{{ include "honeycomb.basicLabels" . }}
{{ include "honeycomb.metrics.selectorLabels" . }}
{{- end }}

{{/*
Events Selector labels
*/}}
{{- define "honeycomb.events.selectorLabels" -}}
{{ include "honeycomb.selectorLabels" . }}
app.kubernetes.io/component: events
{{- end }}

{{/*
Metrics Common labels
*/}}
{{- define "honeycomb.metrics.labels" -}}
{{ include "honeycomb.basicLabels" . }}
{{ include "honeycomb.metrics.selectorLabels" . }}
{{- end }}

{{/*
Metrics Selector labels
*/}}
{{- define "honeycomb.metrics.selectorLabels" -}}
{{ include "honeycomb.selectorLabels" . }}
app.kubernetes.io/component: metrics
{{- end }}
{{/*
Service account name to use
*/}}
{{- define "honeycomb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "honeycomb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
