#!/bin/bash

if systemctl list-unit-files --type=service | grep "docker.service"; then
    echo "[INFO] Docker is already installed"
else
    echo "[INFO] Configuring Docker repo"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get -qq update

    echo "[INFO] Installing container runtimes/interfaces"
    apt-get -qq install -y \
        containerd.io=1.2.13-2 \
        docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
        docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) >/dev/null

    echo "[INFO] Configuring cgroupdriver for systemd OS"
    cat >/etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
    mkdir -p /etc/systemd/system/docker.service.d

    echo "[INFO] Adding vagrant user to docker group"
    usermod -a -G docker vagrant

    echo "[INFO] Starting up Docker"
    systemctl daemon-reload
    systemctl restart docker || systemctl start docker
    systemctl enable docker
fi
