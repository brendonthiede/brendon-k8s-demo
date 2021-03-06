#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Installing kubectl."
wget -O /usr/local/bin/kubectl -q https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl

write_info "Installing yq."
wget -O /usr/local/bin/yq -q https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

write_info "Installing Helm."
wget -O /tmp/helm.tar.gz -q https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz
tar -zxf /tmp/helm.tar.gz -C /tmp/
mv /tmp/linux-amd64/helm /usr/local/bin/helm

chmod +x /usr/local/bin/kubectl /usr/local/bin/yq /usr/local/bin/helm

write_info "Configuring bash completion for kubectl."
echo "source <(kubectl completion bash)" >>/etc/profile
