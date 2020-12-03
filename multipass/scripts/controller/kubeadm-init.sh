#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Starting kubeadm init."
kubeadm init --pod-network-cidr=${POD_CIDR} --kubernetes-version ${KUBERNETES_VERSION}

write_info "Saving join-command script."
mkdir -p ${TMP_DIR}
kubeadm token create --print-join-command >${TMP_DIR}/join-command.sh

write_info "Copying admin kube config for users."
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

mkdir -p /home/${DEFAULT_USER}/.kube
cp -i /etc/kubernetes/admin.conf /home/${DEFAULT_USER}/.kube/config
chown -R $(id -u ${DEFAULT_USER}):$(id -g ${DEFAULT_USER}) /home/${DEFAULT_USER}/.kube
