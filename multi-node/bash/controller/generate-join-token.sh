#!/bin/bash

if [[ -s /etc/setup/join-command.sh ]]; then
    echo "[INFO] Join command already generated."
else
    echo "[INFO] Generating join command"
    kubeadm token create --print-join-command >/etc/setup/join-command.sh
    cp /etc/setup/join-command.sh /vagrant/join-command.sh
fi
