{{- define "invoiceninja.service" -}}
service:
  invoiceninja:
    enabled: true
    primary: true
    type: ClusterIP
    targetSelector: invoiceninja
    ports:
      fastcgi:
        port: 9000
        protocol: tcp
  invoiceninja-nginx:
    enabled: true
    type: NodePort
    targetSelector: nginx
    ports:
      webui:
        enabled: true
        port: {{ .Values.inNetwork.webPort }}
        nodePort: {{ .Values.inNetwork.webPort }}
        targetPort: {{ .Values.inNetwork.webPort }}
        targetSelector: nginx

  # Redis
  redis:
    enabled: true
    type: ClusterIP
    targetSelector: redis
    ports:
      redis:
        enabled: true
        primary: true
        port: 6379
        targetPort: 6379
        targetSelector: redis

  mariadb:
    enabled: true
    type: ClusterIP
    targetSelector: mariadb
    ports:
      mariadb:
        enabled: true
        primary: true
        port: 3306
        targetPort: 3306
        targetSelector: mariadb
{{- end -}}
