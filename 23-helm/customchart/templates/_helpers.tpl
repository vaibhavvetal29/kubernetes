{{- define "customchart.systemlabels" }}
  labels:
     priority: I
     app: frontend
     releasename: "{{ $.Release.Name }}"
{{- end }}