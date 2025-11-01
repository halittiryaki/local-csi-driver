{{- define "local-csi-driver.diskProvisionerInit" -}}
{{- if .Values.diskProvisioner.enabled }}
initContainers:
- name: xfs-disk-setup
  image: {{ .Values.diskProvisioner.image }}
  imagePullPolicy: {{ .Values.diskProvisioner.pullPolicy }}
  restartPolicy: Always
  securityContext:
    privileged: true
  command:
    - "/bin/bash"
    - "-euExo"
    - "pipefail"
    - "-O"
    - "inherit_errexit"
    - "-c"
    - |
      img_path="/host{{ .Values.diskProvisioner.volumeImageDir }}/persistent-volume.img"
      img_dir=$( dirname "${img_path}" )
      mount_path="/host{{ .Values.volumesDir }}"
      
      mkdir -p "${img_dir}"
      if [[ ! -f "${img_path}" ]]; then
        dd if=/dev/zero of="${img_path}" bs=1024 count=0 seek={{ mul .Values.diskProvisioner.sizeGB 1048576 }}
      fi
      
      FS=$(blkid -o value -s TYPE "${img_path}" || true)
      if [[ "${FS}" != "xfs" ]]; then
        mkfs --type=xfs "${img_path}"
      fi
      
      mkdir -p "${mount_path}"
      
      remount_opt=""
      if mountpoint "${mount_path}"; then
        remount_opt="remount,"
      fi
      mount -t xfs -o "${remount_opt}prjquota" "${img_path}" "${mount_path}"
      
      sleep infinity
  readinessProbe:
    exec:
      command:
        - "sh"
        - "-c"
        - "mountpoint -q /host{{ .Values.volumesDir }}"
    initialDelaySeconds: 15
    periodSeconds: 5
    failureThreshold: 3
  volumeMounts:
    - name: hostfs
      mountPath: /host
      mountPropagation: Bidirectional
{{- end }}
{{- end }}