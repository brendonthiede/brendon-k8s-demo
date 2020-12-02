#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

${SCRIPT_DIR}/kubeadm-init.sh
${SCRIPT_DIR}/install-cni.sh
