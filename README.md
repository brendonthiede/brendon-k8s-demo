# minikube Demo

## Purpose

This repo exists for showing some example usage of [Kubernetes](https://kubernetes.io/) on Windows via [minikube](https://minikube.sigs.k8s.io/docs/).

## Context

The reference system for this is using Windows 10 Pro version 1909, build 18363.1139. It has [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10), using the [Ubuntu 20.04](https://www.microsoft.com/store/productId/9N6SVWS3RX71) distro. The system also has [Docker Desktop 2.5](https://hub.docker.com/editions/community/docker-ce-desktop-windows) (which leverages Hyper-V) and [Virtual Box 6.1](https://www.virtualbox.org/wiki/Downloads) (which can work with Hyper-V)

## Setting up Kubernetes

### minikube single node cluster

1. Grab the [installer](https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe) and run it
2. Start a shell running as Administrator and run `minikube start`
3. Open a new shell
    - If you use Windows Terminal you can open a new tab

## Virtual machine multi-node cluster

In order to use this solution, you will need to use WSL in order to run Ansible

1. Install [Virtual Box 6.1](https://www.virtualbox.org/wiki/Downloads) or newer (Hyper-V compatability)
2. Install [Vagrant](https://www.vagrantup.com/downloads), checking in [older versions](https://releases.hashicorp.com/vagrant/) for something with both deb and msi formats (must be version 2.2.14 or newer to work with WSL2).
    1. Install Vagrant in WSL:
    ```bash
    wget -O vagrant.deb https://releases.hashicorp.com/vagrant/2.2.14/vagrant_2.2.14_x86_64.deb
    sudo dpkg -i vagrant.deb
    rm -f vagrant.deb
    vagrant --version
    ```
    2. Install the same version for Windows, e.g. [2.2.14](https://releases.hashicorp.com/vagrant/2.2.14/vagrant_2.2.14_x86_64.msi)
3. Install [Ansible](https://www.digestibledevops.com/devops/2018/12/11/ansible-on-windows.html):
```bash
sudo apt-get update
sudo apt-get install software-properties-common --yes
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible --yes
```
4. Run the following from a WSL Bash prompt to create and intialize the cluster (you will likely need to approve several prompts to give VirtualBox the rights it needs to getting things rolling, at least the first time):
```bash
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
cd ./multi-node/
vagrant up
```

## Setting up tools

If using Bash as your primary shell, you can have kubectl provide command completion by adding the following to `.bashrc`:

```bash
source <(kubectl completion bash)
```
