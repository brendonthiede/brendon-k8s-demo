#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Installing Docker"
curl -sSL get.docker.com | sh || fail "Failed to install Docker"
usermod -aG docker ${DEFAULT_USER}

write_info "Adding Kubernetes apt repo"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - || fail "Failed to get gpg keys from Google."
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list || fail "Failed to add Kubernetes apt repo."

write_info "Installing kubeadm"
apt-get -qq update &&
    apt-get -qq -y install kubeadm >/dev/null || fail "Failed to install kubeadm"

write_info "Disabling swap"
grep -v '^#' /etc/fstab | grep swap && sed -i 's/\(.*swap\)/# \1/' /etc/fstab
[[ $(swapon -s | tail -n1 | awk '{print $3}') -ne 0 ]] && swapoff -a
