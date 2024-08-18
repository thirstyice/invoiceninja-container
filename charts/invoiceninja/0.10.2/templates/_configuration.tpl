{{- define "invoiceninja.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $appKey := (randAlphaNum 32) -}}
  {{- if .Values.inConfig.appKey -}}
    {{- $appKey = .Values.inConfig.appKey -}}
  {{- end -}}

  {{- $dbHost := (printf "%s-mariadb" $fullname) -}}
  {{- $dbUser := "invoiceninja" -}}
  {{- $dbName := "invoiceninja" -}}
  {{- $dbPass := (randAlphaNum 32) -}}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}
  {{- $redisPass := randAlphaNum 32 -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "inDbPass" $dbPass | quote -}}
  {{- $_ := set .Values "inDbHost" $dbHost | quote -}}
  {{- $_ := set .Values "inDbName" $dbName | quote -}}
  {{- $_ := set .Values "inDbUser" $dbUser | quote -}}

secret:
  mariadb-creds:
    enabled: true
    data:
      MARIADB_USER: {{ $dbUser }}
      MARIADB_DATABASE: {{ $dbName }}
      MARIADB_PASSWORD: {{ $dbPass }}
      MARIADB_ROOT_PASSWORD: {{ .Values.inConfig.dbRootPass | quote }}
      MARIADB_HOST: {{ $dbHost }}

  redis-creds:
    enabled: true
    data:
      ALLOW_EMPTY_PASSWORD: "no"
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_HOST: {{ $redisHost }}

  invoiceninja-creds:
    enabled: true
    data:
      APP_URL: {{ .Values.inConfig.appURL | quote }}
      DB_HOST: {{ $dbHost }}
      DB_PORT: "3306"
      DB_DATABASE: {{ $dbName }}
      DB_USERNAME: {{ $dbUser }}
      LOG_CHANNEL: {{ .Values.inConfig.logChannel | quote}}
      MAIL_MAILER: {{ .Values.inConfig.mailer | quote }}
      BROADCAST_DRIVER: redis
      CACHE_DRIVER: redis
      SESSION_DRIVER: redis
      QUEUE_CONNECTION: redis
      PDF_GENERATOR: {{ .Values.inConfig.pdfGenerator | quote }}
      REDIS_HOST: {{ $redisHost }}
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_PORT: "6379"
      REDIS_DB: "0"
      REDIS_CACHE_DB: "1"
      REDIS_BROADCAST_CONNECTION: "default"
      REDIS_CACHE_CONNECTION: "cache"
      REDIS_QUEUE_CONNECTION: "default"
      SESSION_CONNECTION: "default"
      REQUIRE_HTTPS: {{ .Values.inNetwork.requireHttps | quote }}
      TRUSTED_PROXIES: {{ .Values.inConfig.trustedProxies | quote }}
      PHP_MEMORY_LIMIT: {{ printf "%vM" .Values.inConfig.phpMemoryLimit }}
{{- end -}}