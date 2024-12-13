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
Common labels
*/}}
{{- define "honeycomb-observability-pipeline.labels" -}}
helm.sh/chart: {{ include "honeycomb-observability-pipeline.chart" . }}
{{ include "honeycomb-observability-pipeline.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "honeycomb-observability-pipeline.selectorLabels" -}}
app.kubernetes.io/name: {{ include "honeycomb-observability-pipeline.name" . }}-control-plane
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use for the control plane
*/}}
{{- define "honeycomb-observability-pipeline.serviceAccountName" -}}
{{- if .Values.controlPlane.serviceAccount.create }}
{{- default (printf "%s-control-plane" (include "honeycomb-observability-pipeline.fullname" .)) .Values.controlPlane.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.controlPlane.serviceAccount.name }}
{{- end }}
{{- end }}
