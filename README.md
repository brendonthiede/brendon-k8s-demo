# Brendon k8s Demo

## Purpose

This repo exists for showing some example usage of [Kubernetes](https://kubernetes.io/) on Windows.

## Context

The reference system for this is using Windows 10 Pro version 1909, build 18363.1139. It has [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10), using the [Ubuntu 20.04](https://www.microsoft.com/store/productId/9N6SVWS3RX71) distro. The system also has [Docker Desktop 2.5](https://hub.docker.com/editions/community/docker-ce-desktop-windows) (which leverages Hyper-V) and [Virtual Box 6.1](https://www.virtualbox.org/wiki/Downloads) (which can work with Hyper-V)

## Setting up Kubernetes

### minikube single node cluster

1. Grab the [installer](https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe) and run it
2. Start a shell running as Administrator and run `minikube start`
3. Open a new shell
    - If you use Windows Terminal you can open a new tab

## Virtual machine multi-node cluster

While minikube is great for basic Kubernetes functionality, if you want to be able to see how HA, anti-affinity/affinity, etc. work in a more realistic scenario, you need to have more than one worker.

### Kubernetes "The Hard Way"

This solutions relies on [Virtual Box](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/), using the shell provisioner of Vagrant to set up a Kubernetes cluster with a single control plane node and two worker nodes, with the scripting for getting Kubernetes up and running pulling heavily from Kelsey Hightower's [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way). One big difference from Kubernetes The Hard Way is the networking, in particular the usage of HA Proxy on the control plane node for exposing the worker nodes.

To get a local cluster up and running

1. Install [Virtual Box 6.1](https://www.virtualbox.org/wiki/Downloads) or newer (Hyper-V compatibility).
2. Install [Vagrant](https://www.vagrantup.com/downloads).
3. From PowerShell, inside the `multi-node\hardway` directory, run `vagrant up`

After a few minutes, you should return to the prompt and the cluster will be ready.

If you ever decide to remove the cluster you can run `vagrant destroy --force` to delete the VMs. After that, if you even want to remove the downloaded boxes, etc., you also need to delete the .vagrant folder.

### Alternative solution based on kubeadm with Ansible

Notes on an alternative approach that did not succeed can be found here: [Ansible Notes](./ansible-notes.md)

## Setting up tools

If using Bash as your primary shell, you can have kubectl provide command completion by adding the following to `.bashrc`:

```bash
source <(kubectl completion bash)
```

For the mult-node cluster, you can instead opt to use the control plane node, which already has the tooling set up, by running `vagrant ssh k8s-controller` from inside the directory with the Vagrantfile.
