#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

${SCRIPT_DIR}/vm-prep.sh
${SCRIPT_DIR}/ssh-config.sh
${SCRIPT_DIR}/client-tools.sh
