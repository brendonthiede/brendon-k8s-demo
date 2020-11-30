#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Generating kube config for worker node"
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${TMP_DIR}/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${TMP_DIR}/${instance}.kubeconfig >/dev/null

kubectl config set-credentials system:node:${instance} \
    --client-certificate=${TMP_DIR}/${instance}.pem \
    --client-key=${TMP_DIR}/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${TMP_DIR}/${instance}.kubeconfig >/dev/null

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${TMP_DIR}/${instance}.kubeconfig >/dev/null

kubectl config use-context default --kubeconfig=${TMP_DIR}/${instance}.kubeconfig >/dev/null
