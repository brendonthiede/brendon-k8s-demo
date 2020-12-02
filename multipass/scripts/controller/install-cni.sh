#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Copying admin kube config for users"
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

mkdir -p /home/${DEFAULT_USER}/.kube
cp -i /etc/kubernetes/admin.conf /home/${DEFAULT_USER}/.kube/config
chown -R $(id -u ${DEFAULT_USER}):$(id -g ${DEFAULT_USER}) /home/${DEFAULT_USER}/.kube

write_info "Installing flannel CNI"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
