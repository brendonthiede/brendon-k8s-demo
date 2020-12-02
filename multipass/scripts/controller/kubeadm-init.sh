#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Starting kubeadm init"
kubeadm init --pod-network-cidr=${POD_CIDR} --kubernetes-version ${KUBERNETES_VERSION}

write_info "Saving join-command script"
mkdir -p ${TMP_DIR}
kubeadm token create --print-join-command >${TMP_DIR}/join-command.sh
