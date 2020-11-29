#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Installing etcd"
pushd /tmp >/dev/null
wget -O etcd.tar.gz -q https://github.com/etcd-io/etcd/releases/download/v3.4.10/etcd-v3.4.10-linux-amd64.tar.gz

tar -xf etcd.tar.gz
mv etcd*/etcd* /usr/local/bin/
rm -rf etcd*
popd >/dev/null

mkdir -p /etc/etcd /var/lib/etcd
chmod 700 /var/lib/etcd
cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

INTERNAL_IP=$(hostname -I | awk '{print $2}')
ETCD_NAME=$(hostname -s)

cat <<EOF >/etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster k8s-controller=https://${KUBERNETES_PUBLIC_ADDRESS}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

write_info "Starting etcd"
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
