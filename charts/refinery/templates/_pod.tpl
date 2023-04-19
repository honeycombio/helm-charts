{{- define "refinery.pod" -}}
metadata:
  annotations:
    checksum/config: {{ include (print $.Template.BasePath "/configmap-config.yaml") . | sha256sum }}
    {{- with .Values.podAnnotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if .Values.config.PrometheusMetrics.Enabled }}
    prometheus.io/port: "9090"
    prometheus.io/scrape: "true"
    {{- end }}
    {{- if not .Values.LiveReload }}
    checksum/rules: {{ include (print $.Template.BasePath "/configmap-rules.yaml") . | sha256sum }}
    {{- end }}
  labels:
  {{- include "refinery.selectorLabels" . | nindent 4 }}
  {{- with .Values.podLabels }}
  {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  serviceAccountName: {{ include "refinery.serviceAccountName" . }}
  {{- if eq .Values.mode "statefulset" }}
  # The makes the pod hostnames be resolvable.
  setHostnameAsFQDN: true
  {{- end }}
  securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 4 }}
  containers:
    - name: {{ .Chart.Name }}
      securityContext:
      {{- toYaml .Values.securityContext | nindent 8 }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      command:
        - refinery
        - -c
        - /etc/refinery/config.yaml
        - -r
        - /etc/refinery/rules.yaml
        {{- if .Values.debug.enabled }}
        - -d
        {{- end }}
        {{- range .Values.extraCommandArgs }}
        - {{ . }}
        {{- end }}
      {{- with .Values.environment }}
      env:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      ports:
        - name: data
          containerPort: 8080
          protocol: TCP
        - name: grpc
          containerPort: 4317
          protocol: TCP
        - name: peer
          containerPort: 8081
          protocol: TCP
        {{- if .Values.config.PrometheusMetrics.Enabled }}
        - name: metrics
          containerPort: 9090
          protocol: TCP
        {{- end }}
        {{- if .Values.debug.enabled }}
        - name: debug
          containerPort: {{ .Values.debug.port }}
          protocol: TCP
        {{- end }}
      volumeMounts:
        - name: refinery-config
          mountPath: /etc/refinery/
        {{- with .Values.extraVolumeMounts }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      livenessProbe:
        httpGet:
          path: /alive
          port: data
        initialDelaySeconds: 10
        periodSeconds: 10
        failureThreshold: 3
      readinessProbe:
        httpGet:
          path: /alive
          port: data
        initialDelaySeconds: 0
        periodSeconds: 3
        failureThreshold: 5
      resources:
  {{- toYaml .Values.resources | nindent 8 }}
  volumes:
    - name: refinery-config
      projected:
        sources:
          - configMap:
              name: {{ include "refinery.fullname" . }}-config
              items:
                - key: config.yaml
                  path: config.yaml
          - configMap:
            {{- if .Values.RulesConfigMapName }}
              name: {{ .Values.RulesConfigMapName }}
            {{- else }}
              name: {{ include "refinery.fullname" . }}-rules
            {{- end }}
              items:
                - key: rules.yaml
                  path: rules.yaml
    {{- with .Values.extraVolumes }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.nodeSelector }}
  nodeSelector:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations:
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
