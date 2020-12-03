#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Installing NGINX ingress controller."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo update >/dev/null

kubectl create namespace ingress-controller
helm install -n ingress-controller ingress-controller ingress-nginx/ingress-nginx >/dev/null
