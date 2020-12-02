#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Copying admin kube config for users"
mkdir -p /root/.kube
cp -i /tmp/admin.kubeconfig /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

mkdir -p /home/${DEFAULT_USER}/.kube
cp -i /tmp/admin.kubeconfig /home/${DEFAULT_USER}/.kube/config
chown -R $(id -u ${DEFAULT_USER}):$(id -g ${DEFAULT_USER}) /home/${DEFAULT_USER}/.kube

write_info "Joining cluster with join-command"
chmod +x /tmp/join-command.sh
/tmp/join-command.sh
