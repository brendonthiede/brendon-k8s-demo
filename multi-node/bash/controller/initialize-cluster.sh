#!/bin/bash

if [[ -f /home/vagrant/.kube/config ]]; then
    echo "[INFO] /home/vagrant/.kube/config already exists"
else
    echo "[INFO] Running kubeadm init"
    kubeadm init \
        --apiserver-advertise-address="$(hostname -I | awk '{print $2}')" \
        --apiserver-cert-extra-sans="$(hostname -I | sed 's/ $//; s/ /,/g')" \
        --node-name $(hostname) \
        --pod-network-cidr=10.244.0.0/16

    echo "[INFO] Copying kubeconfig for root user"
    mkdir -p /root/.kube
    cp -i /etc/kubernetes/admin.conf /root/.kube/config

    echo "[INFO] Copying kubeconfig for vagrant user"
    mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown -R vagrant:vagrant /home/vagrant/.kube/
fi
