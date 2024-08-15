{{- define "nginx.configuration" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

{{- if .Values.inNetwork.certificateID }}
scaleCertificate:
  invoiceninja-cert:
    enabled: true
    id: {{ .Values.inNetwork.certificateID }}

  {{ $timeout := 60 }}
  {{ $size := .Values.inConfig.maxUploadLimit | default 3 }}
  {{ $useDiffAccessPort := false }}
  {{ $externalAccessPort := ":$server_port" }}
  {{/* Safely access key as it is conditionaly shown */}}
  {{ if hasKey .Values.inNetwork "nginx" }}
    {{ $useDiffAccessPort = .Values.inNetwork.nginx.useDifferentAccessPort }}
    {{ $externalAccessPort = printf ":%v" .Values.inNetwork.nginx.externalAccessPort }}
    {{ $timeout = .Values.inNetwork.nginx.proxyTimeouts | default 60 }}
  {{ end }}
  {{/* If its 443, do not append it on the rewrite at all */}}
  {{ if eq $externalAccessPort ":443" }}
    {{ $externalAccessPort = "" }}
  {{ end }}
configmap:
  nginx:
    enabled: true
    data:
      nginx.conf: |
        events {}
        http {
          server {
            listen {{ .Values.inNetwork.webPort }} ssl http2;
            listen [::]:{{ .Values.inNetwork.webPort }} ssl http2;

            # Redirect HTTP to HTTPS
            error_page 497 301 =307 https://$host{{ $externalAccessPort }}$request_uri;

            ssl_certificate '/etc/nginx-certs/public.crt';
            ssl_certificate_key '/etc/nginx-certs/private.key';

            client_max_body_size {{ $size }}G;

            add_header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload" always;

            location = /robots.txt {
              allow all;
              log_not_found off;
              access_log off;
            }

            location = /.well-known/carddav {
              return 301 $scheme://$host{{ $externalAccessPort }}/remote.php/dav;
            }

            location = /.well-known/caldav {
              return 301 $scheme://$host{{ $externalAccessPort }}/remote.php/dav;
            }
            
            root /var/www/app/public;
            index index.php

            location / {
              try_files $uri $uri/ /index.php?$query_string
            }

            location = /favicon.ico { access_log off; log_not_found off; }
            location = /robots.txt  { access_log off; log_not_found off; }

            location ~ \.php$ {
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass unix:/var/run/php-fpm.sock;
              fastcgi_index index.php;
              include fastcgi_params;
              fastcgi_param SCRIPT_FILENAME /var/www/app/public$fastcgi_script_name;
              fastcgi_buffer_size 16k;
              fastcgi_buffers 4 16k;
            }
          }
        }
{{- end -}}
{{- end -}}
