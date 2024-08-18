{{- define "mariadb.workload" -}}

workload:
{{- include "ix.v1.common.app.mariadb" (dict "name" "mariadb"
                                              "secretName" "mariadb-creds"
                                              "backupPath" "/mariadb-backup"
                                              "resources" .Values.resources
                                        )
}}
{{- end -}}
