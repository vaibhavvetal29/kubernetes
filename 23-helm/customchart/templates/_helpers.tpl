{{- define "customchart.systemlables" }}
  labels:
     function: IT
     app: frontend
     releasename: "{{ $.Release.Name }}"
{{- end }}
{{- define "customchart.appinfo" }}
app_name: "{{ .Chart.Name }}"
app_version: "{{ .Chart.Version }}"
{{- end }}
