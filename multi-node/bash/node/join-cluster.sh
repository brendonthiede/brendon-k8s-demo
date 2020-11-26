#!/bin/bash

if [[ -f /etc/setup/join-command.sh ]]; then
    echo "[INFO] Join command was already setup."
else
    echo "[INFO] Joining node to cluster"
    cp /vagrant/join-command.sh /etc/setup/join-command.sh && chmod a+x /etc/setup/join-command.sh
    sh /etc/setup/join-command.sh
fi
