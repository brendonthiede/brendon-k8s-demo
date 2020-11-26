#!/bin/bash

if which kubeadm; then
    echo "[INFO] kubeadm is already installed"
else
    export DEBIAN_FRONTEND=noninteractive

    echo "[INFO] Configuring Kubernetes apt repo"
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-$(lsb_release -cs) main"
    apt-get -qq update

    echo "[INFO] Installing Kubernetes binaries"
    apt-get -qq install -y kubelet kubeadm kubectl --fix-missing --no-install-recommends >/dev/null

    echo "[INFO] Configuring k8s bash completion"
    kubectl completion bash >/etc/bash_completion.d/kubectl
    kubeadm completion bash >/etc/bash_completion.d/kubeadm

    echo "[INFO] Configuring kubelet node-ip"
    echo "KUBELET_EXTRA_ARGS=--node-ip=$(hostname -I | awk '{print $2}')" >>/etc/default/kubelet

    echo "[INFO] Reloading kubelet"
    systemctl daemon-reload
    systemctl restart kubelet
fi
