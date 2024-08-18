{{- define "invoiceninja.portal" -}}
{{- $protocol := "http" -}}
{{- if .Values.inNetwork.requireHttps -}}
  {{- $protocol = "https" -}}
{{- end -}}
{{- $host := "$node_ip" -}}
{{- $port := .Values.inNetwork.webPort -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ $port | quote }}
  path: "/"
  protocol: {{ $protocol }}
  host: {{ $host | quote }}
{{- end -}}
