{{- define "local-csi-driver.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end -}}

{{- define "local-csi-driver.fullname" -}}
{{- printf "%s-local-csi-driver" .Release.Name }}
{{- end }}

{{- define "local-csi-driver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "local-csi-driver.labels" -}}
{{ include "local-csi-driver.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "local-csi-driver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "local-csi-driver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "local-csi-driver.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "local-csi-driver.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}