{{- define "gitops-app.fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}