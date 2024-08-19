{{- define "nginx.configuration" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

{{- $serverProtocol := "" -}}
{{- if .Values.inNetwork.requireHttps -}}
  {{- $serverProtocol := " ssl http2" -}}
{{- else -}}
  {{- $serverProtocol := " http2" -}}
{{- end -}}

scaleCertificate:
  invoiceninja-cert:
    enabled: true
    id: {{ .Values.inNetwork.certificateID }}

configmap:
  nginx:
    enabled: true
    data:
      nginx.conf: |
        events {}
        http {
          server {
            listen {{ .Values.inNetwork.webPort }} {{ $serverProtocol }};
            listen [::]:{{ .Values.inNetwork.webPort }} {{ $serverProtocol }};

            ssl_certificate '/etc/nginx-certs/public.crt';
            ssl_certificate_key '/etc/nginx-certs/private.key';

            client_max_body_size 1G;

            location = /robots.txt {
              allow all;
              log_not_found off;
              access_log off;
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
              fastcgi_pass invoiceninja:9000;
              fastcgi_index index.php;
              include fastcgi_params;
              fastcgi_param SCRIPT_FILENAME /var/www/app/public$fastcgi_script_name;
              fastcgi_buffer_size 16k;
              fastcgi_buffers 4 16k;
            }
          }
        }
{{- end -}}
