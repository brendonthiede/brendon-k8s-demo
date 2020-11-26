#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sed -i 's/mesg n ||/tty -s \&\& mesg n ||/' .profile

apt-get -qq update

echo "[INFO] Installing common packages"
apt-get -qq install -y \
    apt-transport-https \
    avahi-daemon \
    bash-completion \
    ca-certificates \
    curl \
    ebtables ethtool \
    gnupg-agent \
    gnupg2 \
    libnss-mdns \
    software-properties-common \
    --fix-missing --no-install-recommends >/dev/null

echo "[INFO] Enabling bridge networking"
cat >>/etc/ufw/sysctl.conf <<EOF
net/bridge/bridge-nf-call-ip6tables = 1
net/bridge/bridge-nf-call-iptables = 1
net/bridge/bridge-nf-call-arptables = 1
EOF

echo "[INFO] Disabling swap"
grep -v '^#' /etc/fstab | grep swap && sed -i 's/\(.*swap\)/# \1/' /etc/fstab
[[ $(swapon -s | tail -n1 | awk '{print $3}') -ne 0 ]] && swapoff -a
