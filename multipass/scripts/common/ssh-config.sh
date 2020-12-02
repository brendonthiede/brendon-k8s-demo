#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

exit 0

write_info "Setting up SSH key for root"
mkdir -p /root/.ssh/
cp "${SETUP_DIR}/id_rsa" "${SETUP_DIR}/id_rsa.pub" /root/.ssh/
cat "${SETUP_DIR}/id_rsa.pub" >>/root/.ssh/authorized_keys
chown -R root:root /root/.ssh/
chmod 600 /root/.ssh/id_rsa /root/.ssh/authorized_keys
chmod 644 /root/.ssh/id_rsa.pub

write_info "Setting up SSH key for ${DEFAULT_USER}"
mkdir -p /home/${DEFAULT_USER}/.ssh/
cp "${SETUP_DIR}/id_rsa" "${SETUP_DIR}/id_rsa.pub" /home/${DEFAULT_USER}/.ssh/
cat "${SETUP_DIR}/id_rsa.pub" >>/home/${DEFAULT_USER}/.ssh/authorized_keys
chmod 600 /home/${DEFAULT_USER}/.ssh/id_rsa /home/${DEFAULT_USER}/.ssh/authorized_keys
chmod 644 /home/${DEFAULT_USER}/.ssh/id_rsa.pub

cat <<EOF >/root/.ssh/config
Host *
    IdentityFile ~/.ssh/id_rsa
    CheckHostIP no
    StrictHostKeyChecking no
    GlobalKnownHostsFile no
    UserKnownHostsFile no
EOF

for _vm_encoded_info in $(jq -r '.[] | @base64' ${SETUP_DIR}/vm-list.json); do
    _name="$(echo "${_vm_encoded_info}" | base64 -d | jq -r '.name')"
    _ipv4="$(echo "${_vm_encoded_info}" | base64 -d | jq -r '.ipv4[0]')"
    cat <<EOF >>/root/.ssh/config
Host ${_name}
    HostName ${_ipv4}
EOF
done

cp /root/.ssh/config /home/${DEFAULT_USER}/.ssh/config
chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}/.ssh/

write_info "Setting up /etc/hosts"
cat <<EOF >/etc/hosts
127.0.0.1       localhost
127.0.1.1       ${DEFAULT_USER}.vm      ${DEFAULT_USER}

10.0.0.10       k8s-controller
10.0.0.11       node-1
10.0.0.12       node-2
EOF

write_info "Modifying sysctl.conf settings."
sed -ri 's/^(net.bridge.bridge-nf-call-(ip6|ip|arp)tables)[ =].*/\1 = 1/g' /etc/sysctl.conf
for _setting in vm.overcommit_memory=1 vm.panic_on_oom=0 kernel.panic=10 kernel.panic_on_oops=1; do
    _key="${_setting%=*}"
    _value="${_setting#*=}"
    sed -i "/^${_key}[ ]*=/d" /etc/sysctl.conf
    printf '\n%s' "${_setting}" >>/etc/sysctl.conf
done
service procps start
