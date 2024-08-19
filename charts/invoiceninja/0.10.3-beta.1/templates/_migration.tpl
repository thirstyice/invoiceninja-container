{{- define "invoiceninja.get-versions" -}}
  {{- $oldChartVersion := "" -}}
  {{- $newChartVersion := "" -}}

  {{/* Safely access the context, so it wont block CI */}}
  {{- if hasKey .Values.global "ixChartContext" -}}
    {{- if .Values.global.ixChartContext.upgradeMetadata -}}

      {{- $oldChartVersion = .Values.global.ixChartContext.upgradeMetadata.oldChartVersion -}}
      {{- $newChartVersion = .Values.global.ixChartContext.upgradeMetadata.newChartVersion -}}
      {{- if and (not $oldChartVersion) (not $newChartVersion) -}}
        {{- fail "Upgrade Metadata is missing. Cannot proceed" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- toYaml (dict "old" $oldChartVersion "new" $newChartVersion) -}}
{{- end -}}

{{- define "invoiceninja.migration" -}}
  {{- $versions := (fromYaml (include "invoiceninja.get-versions" $)) -}}
  {{- if and $versions.old $versions.new -}}
    {{- $oldV := semver $versions.old -}}
    {{- $newV := semver $versions.new -}}
  {{- end -}}
{{- end -}}

{{- define "invoiceninja.is-migration" -}}
  {{- $isMigration := "" -}}
  {{- $versions := (fromYaml (include "invoicecninja.get-versions" $)) -}}
  {{- if $versions.old -}}
    {{- $oldV := semver $versions.old -}}
    {{- if and (eq $oldV.Major 1) (eq ($oldV.Minor | int) 6) (eq ($oldV.Patch | int) 61) -}}
      {{- $isMigration = "true" -}}
    {{- end -}}
  {{- end -}}

  {{- $isMigration -}}
{{- end -}}
