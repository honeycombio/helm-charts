{{/*
Merge user-supplied `MaxAlloc` if present. Otherwise, calculate the value.
*/}}
{{- define "refinery.config.InMemCollector" -}}
{{- $InMemCollectorAlloc := get .Values.config.InMemCollector "MaxAlloc" }}
{{- if (not $InMemCollectorAlloc) }}
{{- $_ := set $InMemCollectorAlloc "MaxAlloc" (mulf .Values.resources.requests.memory 0.75) }}
{{- end }}
{{- .Values.config | toYaml }}
{{- end }}
