#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# First time setup
[[ -f ~/.ssh/id_rsa ]] || ssh-keygen -t RSA -b 4096 -C "${USER}@$(hostname)" -f "${HOME}/.ssh/id_rsa" -q -N ""
grep 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' ~/.bashrc >/dev/null || echo 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' >>~/.bashrc
grep 'export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"' ~/.bashrc >/dev/null || echo 'export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"' >>~/.bashrc
grep 'vagrant-.*/contrib/bash/completion\.sh' ~/.bashrc >/dev/null || vagrant autocomplete install

export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
echo $PATH | grep '/mnt/c/Program Files/Oracle/VirtualBox' >/dev/null || export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"

pushd ${SCRIPT_DIR} >/dev/null
vagrant up
popd >/dev/null
