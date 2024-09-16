{{/*
Expand the name of the chart.
*/}}
{{- define "honeycomb-straws.name" -}}
{{- default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
