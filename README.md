# Brendon k8s Demo

## Purpose

This repo exists for showing some example installation and usage of [Kubernetes](https://kubernetes.io/), focusing on Windows, though it should work wherever you can install Virtual Box and Vagrant.

## Context

The reference system for this is using Windows 10 Pro version 1909, build 18363.1139. It has [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10), using the [Ubuntu 20.04](https://www.microsoft.com/store/productId/9N6SVWS3RX71) distro (WSL2 is not needed for "The Hard Way" below). The system also has [Docker Desktop 2.5](https://hub.docker.com/editions/community/docker-ce-desktop-windows) (which leverages Hyper-V) and [Virtual Box 6.1](https://www.virtualbox.org/wiki/Downloads) (which can work with Hyper-V)

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

After 5 - 10 minutes, you should return to the prompt and the cluster will be ready.

If you ever decide to remove the cluster you can run `vagrant destroy --force` to delete the VMs.

### Alternative solution based on kubeadm with Ansible

Notes on an alternative approach that did not succeed can be found here: [Ansible Notes](./docs/ansible-notes.md)

## Setting up tools

### Vagrant Box

For the multi-node cluster, you can instead opt to use the control plane node, which already has the tooling set up, by running `vagrant ssh k8s-controller` from inside the directory with the Vagrantfile.

### PowerShell

#### kubectl

Depending on how you installed Kubernetes, you may already have kubectl installed. If not, you can choose one of the options in the instructions for "[Install kubectl on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows)".

## Demo App Setup

In order to interact with the cluster you need to set up kubectl to know about the cluster configuration. There are [several methods](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), but this is a quick one:

```powershell
New-Item -Name $env:HOMEPATH/.kube -Type Directory -Force
Copy-Item -Path .\tmp\admin.kubeconfig -Destination $env:HOMEPATH/.kube/config -Force
kubectl cluster-info
```
