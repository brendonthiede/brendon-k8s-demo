#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Disabling swap."
grep -v '^#' /etc/fstab | grep swap && sed -i 's/\(.*swap\)/# \1/' /etc/fstab
[[ $(swapon -s | tail -n1 | awk '{print $3}') -ne 0 ]] && swapoff -a

write_info "Load kernel modules for bridge and overlay networks."
grep ^br_netfilter$ /etc/modules-load.d/modules.conf || echo br_netfilter >>/etc/modules-load.d/modules.conf
grep ^overlay$ /etc/modules-load.d/modules.conf || echo overlay >>/etc/modules-load.d/modules.conf
modprobe overlay >/dev/null || fail "Failed to load overlay kernel module."
modprobe br_netfilter >/dev/null || fail "Failed to load br_netfilter kernel module."

write_info "Updating sysctl configuratoin for exposing bridged traffic."
sed -ri 's/^(net.bridge.bridge-nf-call-(ip6|ip|arp)tables)[ =].*/\1 = 1/g' /etc/sysctl.conf
sysctl --system >/dev/null || fail "Failed to update sysctl."

write_info "Installing apt-transport-https, ca-certificates, curl, gnupg-agent, and software-properties-common."
apt-get -qq update >/dev/null
apt-get -qq -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    --no-install-recommends >/dev/null || fail "Failed to install apt packages."

write_info "Adding extra apt repos."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -qq - >/dev/null || fail "Failed to get gpg keys from Google."
add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null || fail "Failed to add Kubernetes apt repo."
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -qq - >/dev/null || fail "Failed to get gpg keys from Docker."
add-apt-repository "deb [arch=${OS_ARCH}] https://download.docker.com/linux/ubuntu ${OS_VERSION} stable" >/dev/null || fail "Failed to add Docker apt repo."

write_info "Installing bash-completion, Docker, jq, and kubeadm."
apt-get -qq update >/dev/null
apt-get -qq -y install \
    bash-completion \
    containerd.io \
    docker-ce=${DOCKER_VERSION} \
    docker-ce-cli=${DOCKER_VERSION} \
    jq \
    kubeadm \
    --no-install-recommends >/dev/null

write_info "Configuring Docker for systemd."
sed -i 's|^\(ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock\)$|\1 --exec-opt native.cgroupdriver=systemd|' /lib/systemd/system/docker.service

write_info "Giving ${DEFAULT_USER} user access to docker."
usermod -aG docker ${DEFAULT_USER}

write_info "Reloading Docker."
systemctl daemon-reload
systemctl restart docker
