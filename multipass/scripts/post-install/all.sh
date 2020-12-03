#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

${SCRIPT_DIR}/install-ingress-controller.sh
