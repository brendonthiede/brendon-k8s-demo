#!/bin/bash

# kubectl apply -f https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/calico.yaml

echo "[INFO] Downloading flannel resource definition"
curl -sS -o kube-flannel.yml https://raw.githubusercontent.com/coreos/flannel/v0.13.0/Documentation/kube-flannel.yml

echo "[INFO] Configuring flannel for Vagrant NIC"
sed -i.bak 's|"/opt/bin/flanneld",|"/opt/bin/flanneld", "--iface=enp0s8",|' kube-flannel.yml

echo "[INFO] Installing flannel"
kubectl apply -f kube-flannel.yml

echo "[INFO] Reloading kubelet"
systemctl daemon-reload
systemctl restart kubelet
