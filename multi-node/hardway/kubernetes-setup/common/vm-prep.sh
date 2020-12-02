#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

if [[ "$(hostname -s)" == "k8s-controller" ]]; then
    write_info "Running one time commands for first controller"
    write_info "Creating/emptying temp directory at ${TMP_DIR}"
    mkdir -p ${TMP_DIR} >/dev/null
    rm -rf ${TMP_DIR}/*

    write_info "Creating intra-cluster SSH keys"
    ssh-keygen -t RSA -b 4096 -C "intra-cluster shared key" -f "${TMP_DIR}/id_rsa" -q -N ""
fi

write_info "Setting up SSH key for root"
mkdir -p /root/.ssh/
cp "${TMP_DIR}/id_rsa" "${TMP_DIR}/id_rsa.pub" /root/.ssh/
cat "${TMP_DIR}/id_rsa.pub" >>/root/.ssh/authorized_keys
chown -R root:root /root/.ssh/
chmod 600 /root/.ssh/id_rsa /root/.ssh/authorized_keys
chmod 644 /root/.ssh/id_rsa.pub

write_info "Setting up SSH key for vagrant"
mkdir -p /home/vagrant/.ssh/
cp "${TMP_DIR}/id_rsa" "${TMP_DIR}/id_rsa.pub" /home/vagrant/.ssh/
cat "${TMP_DIR}/id_rsa.pub" >>/home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/id_rsa /home/vagrant/.ssh/authorized_keys
chmod 644 /home/vagrant/.ssh/id_rsa.pub

cat >/root/.ssh/config <<EOF
Host *
    IdentityFile ~/.ssh/id_rsa
    CheckHostIP no
    StrictHostKeyChecking no
    GlobalKnownHostsFile no
    UserKnownHostsFile no
Host k8s-controller
    HostName 10.0.0.10
Host node-1
    HostName 10.0.0.11
Host node-2
    HostName 10.0.0.12
EOF

cp /root/.ssh/config /home/vagrant/.ssh/config
chown -R vagrant:vagrant /home/vagrant/.ssh/

write_info "Setting up /etc/hosts"
cat <<EOF >/etc/hosts
127.0.0.1       localhost
127.0.1.1       vagrant.vm      vagrant

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