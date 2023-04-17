#!/bin/bash

set -x

DIR_NAME="/tmp/manifests/bootstrap-before-pivot"

# Check if manifest directory exists
if [ -d "${DIR_NAME}" ]; then
  DIR_NAME="/tmp/manifests/bootstrap-after-repivot"
  mkdir -p "${DIR_NAME}"
else
  mkdir -p "${DIR_NAME}"
fi

manifests=(
  bmh
  hardwaredata
  cluster
  deployment
  machine
  machinedeployment
  machinehealthchecks
  machinesets
  machinepools
  m3cluster
  m3machine
  metal3machinetemplate
  kubeadmconfig
  kubeadmconfigtemplates
  kubeadmcontrolplane
  replicaset
  ippool
  ipclaim
  ipaddress
  m3data
  m3dataclaim
  m3datatemplate
)

NAMESPACES="$(kubectl get namespace -o jsonpath='{.items[*].metadata.name}')"
for NAMESPACE in ${NAMESPACES}; do
  for kind in "${manifests[@]}"; do
    mkdir -p "${DIR_NAME}/${kind}"
    for name in $(kubectl get -n "${NAMESPACE}" -o name "${kind}" || true); do
      kubectl get -n "${NAMESPACE}" -o yaml "${name}" | tee "${DIR_NAME}/${kind}/$(basename "${name}").yaml" || true
    done
  done
done