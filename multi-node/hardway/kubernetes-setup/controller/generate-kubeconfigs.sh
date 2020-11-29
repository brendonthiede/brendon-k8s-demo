#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

generate_kube_config() {
    local -r _config_name="$1"
    local -r _ip_address="$2"
    local -r _user="$3"

    local -r _config_path="${TMP_DIR}/${_config_name}.kubeconfig"

    write_info "Generating kube config for ${_config_name}"
    kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=${TMP_DIR}/ca.pem \
        --embed-certs=true \
        --server=https://${_ip_address}:6443 \
        --kubeconfig=${_config_path} >/dev/null

    kubectl config set-credentials ${_user} \
        --client-certificate=${TMP_DIR}/${_config_name}.pem \
        --client-key=${TMP_DIR}/${_config_name}-key.pem \
        --embed-certs=true \
        --kubeconfig=${_config_path} >/dev/null

    kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=${_user} \
        --kubeconfig=${_config_path} >/dev/null

    kubectl config use-context default --kubeconfig=${_config_path} >/dev/null

    assert_file_exists ${_config_path}
}

generate_kube_config "kube-proxy" "${KUBERNETES_PUBLIC_ADDRESS}" "system:kube-proxy"
generate_kube_config "kube-controller-manager" "127.0.0.1" "system:kube-controller-manager"
generate_kube_config "kube-scheduler" "127.0.0.1" "system:kube-scheduler"
generate_kube_config "admin" "127.0.0.1" "admin"

write_info "Copying admin kube config for root and vagrant users"
mkdir -p /root/.kube
cp ${TMP_DIR}/admin.kubeconfig /root/.kube/config

mkdir -p /home/vagrant/.kube
cp ${TMP_DIR}/admin.kubeconfig /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
