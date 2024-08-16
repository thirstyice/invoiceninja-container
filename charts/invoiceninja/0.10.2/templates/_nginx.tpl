{{- define "nginx.workload" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
workload:
  nginx:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        nginx:
          enabled: true
          primary: true
          imageSelector: nginxImage
          probes:
            liveness:
              enabled: true
              type: tcp
              port: {{ .Values.inNetwork.webPort }}
            readiness:
              enabled: true
              type: tcp
              port: {{ .Values.inNetwork.webPort }}
{{- end -}}
