#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

pushd ${TMP_DIR} >/dev/null

/etc/setup/node/generate-certs.sh || fail
/etc/setup/node/generate-kubeconfigs.sh || fail
/etc/setup/node/bootstrap-worker-node.sh || fail

popd >/dev/null
