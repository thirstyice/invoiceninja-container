{{- define "invoiceninja.workload" -}}
workload:
  invoiceninja:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        invoiceninja:
          enabled: true
          primary: true
          imageSelector: image
          envFrom:
            - secretRef:
                name: invoiceninja-creds
          {{ with .Values.inConfig.extraEnvVars }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - pgrep
                - phpfpm
              spec:
                initialDelaySeconds: 120
                periodSeconds: 10
                timeoutSeconds: 5
                failureThreshold: 6
                successThreshold: 1
            readiness:
              enabled: true
              type: tcp
              port: 9000
              httpHeaders:
                Host: localhost
              spec:
                initialDelaySeconds: 15
                periodSeconds: 10
                timeoutSeconds: 5
                failureThreshold: 6
                successThreshold: 1
      initContainers:
      {{- include "ix.v1.common.app.mariadbWait" (dict "name" "mariadb-wait"
                                                        "secretName" "mariadb-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
{{- end -}}
