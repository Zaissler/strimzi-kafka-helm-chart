{{/*
Expand the name of the chart.
*/}}
{{- define "kafka-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kafka-cluster.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kafka-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafka-cluster.labels" -}}
helm.sh/chart: {{ include "kafka-cluster.chart" . }}
{{ include "kafka-cluster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafka-cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafka-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Get deployment mode based on values
Returns: single-node, dual-role, or separated-roles
*/}}
{{- define "kafka-cluster.deploymentMode" -}}
{{- if .Values.deploymentMode }}
{{- .Values.deploymentMode }}
{{- else if eq (.Values.nodepool.replicas | int) 1 }}
{{- "single-node" }}
{{- else if and (has "broker" .Values.nodepool.roles) (has "controller" .Values.nodepool.roles) }}
{{- "dual-role" }}
{{- else }}
{{- "separated-roles" }}
{{- end }}
{{- end }}

{{/*
Get storage type
*/}}
{{- define "kafka-cluster.storageType" -}}
{{- if .Values.storage }}
{{- .Values.storage.type | default .Values.nodepool.storage.type }}
{{- else }}
{{- .Values.nodepool.storage.type }}
{{- end }}
{{- end }}

{{/*
Calculate replication factors based on deployment mode
*/}}
{{- define "kafka-cluster.replicationFactor" -}}
{{- $mode := include "kafka-cluster.deploymentMode" . }}
{{- if eq $mode "single-node" }}
{{- 1 }}
{{- else }}
{{- .Values.kafka.replication.defaultReplicationFactor | default 3 }}
{{- end }}
{{- end }}

{{/*
Calculate min.insync.replicas based on deployment mode
*/}}
{{- define "kafka-cluster.minInsyncReplicas" -}}
{{- $mode := include "kafka-cluster.deploymentMode" . }}
{{- if eq $mode "single-node" }}
{{- 1 }}
{{- else }}
{{- .Values.kafka.replication.minInsyncReplicas | default 2 }}
{{- end }}
{{- end }}

{{/*
Determine if nodepools should be created
*/}}
{{- define "kafka-cluster.createNodePools" -}}
{{- if .Values.nodepools }}
{{- true }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{/*
Get cluster name
*/}}
{{- define "kafka-cluster.clusterName" -}}
{{- .Values.kafka.clusterName | default "kraft-cluster" }}
{{- end }}

{{/*
Generate node pool storage configuration
*/}}
{{- define "kafka-cluster.nodePoolStorage" -}}
{{- $storageType := .storageType | default "persistent-claim" }}
{{- if eq $storageType "jbod" }}
type: jbod
volumes:
{{- range .jbodVolumes }}
  - id: {{ .id }}
    type: {{ .type }}
    {{- if eq .type "persistent-claim" }}
    size: {{ .size }}
    deleteClaim: {{ .deleteClaim | default false }}
    {{- end }}
    kraftMetadata: {{ .kraftMetadata | default "shared" }}
{{- end }}
{{- else if eq $storageType "persistent-claim" }}
type: jbod
volumes:
  - id: 0
    type: persistent-claim
    size: {{ .size | default "1Gi" }}
    deleteClaim: {{ .deleteClaim | default false }}
    kraftMetadata: shared
{{- else if eq $storageType "ephemeral" }}
type: jbod
volumes:
  - id: 0
    type: ephemeral
    kraftMetadata: shared
{{- end }}
{{- end }}

{{/*
Check if EntityOperator should be enabled
*/}}
{{- define "kafka-cluster.entityOperatorEnabled" -}}
{{- if hasKey .Values "entityOperator" }}
{{- .Values.entityOperator.enabled | default true }}
{{- else }}
{{- true }}
{{- end }}
{{- end }}
