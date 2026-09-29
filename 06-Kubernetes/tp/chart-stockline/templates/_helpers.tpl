{{/* Nom complet des ressources : <release>-stockline tronqué à 63 caractères */}}
{{- define "stockline.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Labels communs à toutes les ressources du chart */}}
{{- define "stockline.labels" -}}
app.kubernetes.io/part-of: stockline
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/* Tag d'image : valeur explicite ou appVersion du Chart */}}
{{- define "stockline.apiImage" -}}
{{ .Values.api.image.repository }}:{{ .Values.api.image.tag | default .Chart.AppVersion }}
{{- end -}}

{{- define "stockline.frontImage" -}}
{{ .Values.front.image.repository }}:{{ .Values.front.image.tag | default .Chart.AppVersion }}
{{- end -}}
