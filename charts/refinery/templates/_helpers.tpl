{{/*
Expand the name of the chart.
*/}}
{{- define "refinery.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "refinery.fullname" -}}
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
{{- define "refinery.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "refinery.labels" -}}
helm.sh/chart: {{ include "refinery.chart" . }}
{{ include "refinery.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels}}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "refinery.selectorLabels" -}}
app.kubernetes.io/name: {{ include "refinery.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create a default fully qualified app name for the redis component.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "refinery.redis.fullname" -}}
{{ include "refinery.fullname" . }}-redis
{{- end }}

{{/*
Common labels for redis
*/}}
{{- define "refinery.redis.labels" -}}
helm.sh/chart: {{ include "refinery.chart" . }}
{{ include "refinery.redis.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.redis.commonLabels}}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels for redis
*/}}
{{- define "refinery.redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "refinery.name" . }}-redis
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "refinery.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "refinery.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Build config file for Refinery
*/}}
{{- define "refinery.config" -}}
{{- $config := deepCopy .Values.config }}
{{- if .Values.debug.enabled }}
{{-   $debugging := get $config "Debugging" }}
{{-   if not $debugging }}
{{-     $_ := set $config "Debugging" (dict "DebugServiceAddr" (include "refinery.DebugServiceAddr" .)) }}
{{-   else }}
{{-     $debugServiceAddr := get $debugging "DebugServiceAddr" }}
{{-     if not $debugServiceAddr }}
{{-       $_ := set $debugging "DebugServiceAddr" (include "refinery.DebugServiceAddr" .) }}
{{-     end }}
{{-   end }}   
{{- end }}
{{- if eq .Values.region "production-eu" }}
{{- $config = mustMergeOverwrite (include "refinery.productionEUConfig" .Values | fromYaml) $config }}
{{- end }}
{{- if eq .Values.region "dogfood-eu" }}
{{- $config = mustMergeOverwrite (include "refinery.dogfoodEUConfig" .Values | fromYaml) $config }}
{{- end }}
{{- if eq .Values.region "kibble-eu" }}
{{- $config = mustMergeOverwrite (include "refinery.kibbleEUConfig" .Values | fromYaml) $config }}
{{- end }}
{{- if eq .Values.region "dogfood" }}
{{- $config = mustMergeOverwrite (include "refinery.dogfoodConfig" .Values | fromYaml) $config }}
{{- end }}
{{- if eq .Values.region "kibble" }}
{{- $config = mustMergeOverwrite (include "refinery.kibbleConfig" .Values | fromYaml) $config }}
{{- end }}
{{- if eq .Values.region "local" }}
{{- $config = mustMergeOverwrite (include "refinery.localConfig" .Values | fromYaml) $config }}
{{- end }}
{{- tpl (toYaml $config) . }}
{{- end }}

{{- define "refinery.DebugServiceAddr" -}}
{{- printf "localhost:%v" .Values.debug.port }}
{{- end}}

{{- define "refinery.productionEUConfig" -}}
Network:
  HoneycombAPI: https://api.eu1.honeycomb.io
HoneycombLogger:
  APIHost: https://api.eu1.honeycomb.io
LegacyMetrics:
  APIHost: https://api.eu1.honeycomb.io
OTelMetrics:
  APIHost: https://api.eu1.honeycomb.io
OTelTracing:
  APIHost: https://api.eu1.honeycomb.io
{{- end }}

{{- define "refinery.dogfoodEUConfig" -}}
Network:
  HoneycombAPI: https://api.dogfood-eu1.honeycomb.io
HoneycombLogger:
  APIHost: https://api.dogfood-eu1.honeycomb.io
LegacyMetrics:
  APIHost: https://api.dogfood-eu1.honeycomb.io
OTelMetrics:
  APIHost: https://api.dogfood-eu1.honeycomb.io
OTelTracing:
  APIHost: https://api.dogfood-eu1.honeycomb.io
{{- end }}

{{- define "refinery.kibbleEUConfig" -}}
Network:
  HoneycombAPI: https://api.kibble-eu1.honeycomb.io
HoneycombLogger:
  APIHost: https://api.kibble-eu1.honeycomb.io
LegacyMetrics:
  APIHost: https://api.kibble-eu1.honeycomb.io
OTelMetrics:
  APIHost: https://api.kibble-eu1.honeycomb.io
OTelTracing:
  APIHost: https://api.kibble-eu1.honeycomb.io
{{- end }}

{{- define "refinery.dogfoodConfig" -}}
Network:
  HoneycombAPI: https://api-dogfood.honeycomb.io
HoneycombLogger:
  APIHost: https://api-dogfood.honeycomb.io
LegacyMetrics:
  APIHost: https://api-dogfood.honeycomb.io
OTelMetrics:
  APIHost: https://api-dogfood.honeycomb.io
OTelTracing:
  APIHost: https://api-dogfood.honeycomb.io
{{- end }}

{{- define "refinery.kibbleConfig" -}}
Network:
  HoneycombAPI: https://api-kibble.honeycomb.io
HoneycombLogger:
  APIHost: https://api-kibble.honeycomb.io
LegacyMetrics:
  APIHost: https://api-kibble.honeycomb.io
OTelMetrics:
  APIHost: https://api-kibble.honeycomb.io
OTelTracing:
  APIHost: https://api-kibble.honeycomb.io
{{- end }}

{{- define "refinery.localConfig" -}}
Network:
  HoneycombAPI: http://localhost:8081
HoneycombLogger:
  APIHost: http://localhost:8081
LegacyMetrics:
  APIHost: http://localhost:8081
OTelMetrics:
  APIHost: http://localhost:8081
OTelTracing:
  APIHost: http://localhost:8081
{{- end }}

{{/*
Build rules file for Refinery
*/}}
{{- define "refinery.rules" -}}
{{- $rules := deepCopy .Values.rules }}
{{- $default := get $rules.Samplers "__default__" }}
{{- if not $default }}
{{-   $_ := set $rules.Samplers "__default__" (include "refinery.defaultRules" . | fromYaml) }}
{{- end }} 
{{- tpl (toYaml $rules) . }}
{{- end }}

{{- define "refinery.defaultRules" -}}
DeterministicSampler:
  SampleRate: 1
{{- end}}
