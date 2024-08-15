{{- define "invoiceninja.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

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

  {{- $dbURL := (printf "sql://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  mariadb-creds:
    enabled: true
    data:
      MARIADB_USER: {{ $dbUser }}
      MARIADB_DATABASE: {{ $dbName }}
      MARIADB_PASSWORD: {{ $dbPass }}
      MARIADB_ROOT_PASSWORD: {{ $dbRootPass }}
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
      APP_URL: {{ include "invoiceninja.url" . | quote }}
      DB_HOST: {{ $dbHost }}
      DB_PORT: {{ $dbPort }}
      DB_DATABASE: {{ $dbName }}
      DB_USERNAME: {{ $dbUser }}
      DB_PASSWORD: {{ $dbPass }}
      LOG_CHANNEL: {{ .Values.logChannel | default stderr | quote}}
      MAIL_MAILER: {{ .Values.mailer | quote }}
      BROADCAST_DRIVER: redis
      CACHE_DRIVER: redis
      SESSION_DRIVER: redis
      QUEUE_CONNECTION: redis
      PDF_GENERATOR: {{ .Values.pdfGenerator | quote }}
      REDIS_HOST: {{ $redisHost }}
      REDIS_PORT: "6379"
      REDIS_DB:
      REDIS_CACHE_DB:
      REDIS_BROADCAST_CONNECTION:
      REDIS_CACHE_CONNECTION:
      REDIS_QUEUE_CONNECTION:
      SESSION_CONNECTION:
      REQUIRE_HTTPS:
      TRUSTED_PROXIES:


      REDIS_HOST_PASSWORD: {{ $redisPass }}
      PHP_UPLOAD_LIMIT: {{ printf "%vG" .Values.ncConfig.maxUploadLimit | default 3 }}
      PHP_MEMORY_LIMIT: {{ printf "%vM" .Values.ncConfig.phpMemoryLimit | default 512 }}
  postgres-backup-creds:
    enabled: true
    annotations:
      helm.sh/hook: "pre-upgrade"
      helm.sh/hook-delete-policy: "hook-succeeded"
      helm.sh/hook-weight: "1"
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName }}
  {{- end }}
{{- end -}}
