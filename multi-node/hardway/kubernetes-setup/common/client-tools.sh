#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

apt-get -qq update >/dev/null
apt-get -qq install jq >/dev/null

wget -O /usr/local/bin/cfssl -q https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64
wget -O /usr/local/bin/cfssljson -q https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssljson_1.5.0_linux_amd64
wget -O /usr/local/bin/kubectl -q https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl
wget -O /usr/local/bin/yq -q https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson /usr/local/bin/kubectl /usr/local/bin/yq
