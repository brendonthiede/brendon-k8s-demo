#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

pushd ${TMP_DIR} >/dev/null

/etc/setup/controller/generate-certs.sh || fail
/etc/setup/controller/bootstrap-etcd.sh || fail
/etc/setup/controller/generate-kubeconfigs.sh || fail
/etc/setup/controller/generate-encryption-key.sh || fail
/etc/setup/controller/bootstrap-control-plane.sh || fail
/etc/setup/controller/setup-node-lb.sh || fail

popd >/dev/null
