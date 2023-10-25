# Brendon k8s Demo

## Purpose

This repo exists for showing some example installation and usage of [Kubernetes](https://kubernetes.io/), focusing on Windows, though it should work wherever you can install Virtual Box and Vagrant.

## Context

The reference system for this is using Windows 10 Pro version 1909, build 18363.1139. It has [Docker Desktop 2.5](https://hub.docker.com/editions/community/docker-ce-desktop-windows) (which leverages Hyper-V) and [Virtual Box 6.1](https://www.virtualbox.org/wiki/Downloads) (which can work with Hyper-V). You should not need WSL in order to use the examples below, and you should only need either Virtual Box _or_ Hyper-V in order to work with Multipass.

## Client tools

You will need to install [Multipass](https://multipass.run/) ([docs](https://multipass.run/docs/installing-on-windows)) to use the Multipass installations below. Before doing so, decide if you will want to use Hyper-V with it, or Virtual Box, and install whichever of those you would like first. Hyper-V can sometimes conflict with other software on your system.

If you want to use Kubernetes from your host OS, the following are recommended, though only kubectl is required:

* Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) either by using Chocolatey or by downloading it and storing it as kubectl.exe somewhere in your path.
* Install [helm](https://helm.sh/docs/intro/install/) using Chocolatey.
* Install [jq](https://stedolan.github.io/jq/download/) either by using Chocolatey or by downloading it and storing it as jq.exe somewhere in your path.
* Install [yq](https://github.com/mikefarah/yq) using Chocolatey.

You can also install command completion in PowerShell (not nearly as good as the Bash completion at this time, but still very useful) by running `Install-Module -Name PSKubectlCompletion` from an Administrator shell and then using `Import-Module PSKubectlCompletion` from the shell instance you will be using.

## minikube single node cluster

minikube is tried and true and has good plugin support in VS Code. It runs as services in Windows without a full VM, so it may use less resources than other solutions.

1. Grab the [installer](https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe) and run it
2. Start a shell running as Administrator and run `minikube start`
3. Open a new shell
    * If you use Windows Terminal you can open a new tab

## k3s single node cluster

k3s is a new option from Rancher that runs as a single binary, with _most_ of the capabilities of a full Kubernetes cluster. To get it running in a Multipass VM and configure kubectl locally, run the following:

```powershell
multipass launch --name k3s --cpus 4 --mem 4g --disk 20g
multipass exec k3s -- bash -c 'curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -'
multipass exec k3s -- sudo bash -c 'apt-get update && su apt-get install jq -y'
multipass exec k3s -- sudo bash -c 'wget -O /usr/local/bin/yq -q https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq'
multipass exec k3s -- sudo bash -c 'wget -O /tmp/helm.tgz https://get.helm.sh/helm-v3.4.2-linux-amd64.tar.gz && cd /tmp && tar -zxf helm.tgz && mv linux-amd64/helm /usr/local/bin/'
$mpIP = (multipass list --format json | jq -r '.list[] | select(.name == \"k3s\") | .ipv4[0]')
((multipass exec k3s -- sudo cat /etc/rancher/k3s/k3s.yaml) -replace '127.0.0.1',$mpIP) |  Set-Content -Path $env:USERPROFILE\.kube\config
```

If all pods are stuck pending and have an event with a message like "0/1 nodes are available: 1 node(s) had taint {node.cloudprovider.kubernetes.io/uninitialized: true}, that the pod didn't tolerate." you can remove the taint manually with the following:

```powershell
kubectl taint nodes k3s node.cloudprovider.kubernetes.io/uninitialized-
```

### Credit

Credit to [Jason Yee](https://jyeee.medium.com/?source=post_page-----14c31af12b7a--------------------------------) for his article [Rancher 2.4 & Kubernetes on your Windows 10 laptop with multipass & k3s — Elasticsearch/Kibana in minutes!](https://jyeee.medium.com/rancher-2-4-14c31af12b7a), which inspired this solution.

## kubeadm multi-node cluster

While minikube is great for basic Kubernetes functionality, if you want to be able to see how HA, anti-affinity, affinity, taints, tolerations, etc. work in a more realistic scenario, you need to have more than one worker. This cluster will give you a three node cluster, composed of one control plane node and two worker nodes. You should be able to launch the VMs and get them setup by running:

```powershell
.\multipass\cluster-init.ps1
```

Depending on how your system is set up, you may need to relax execution policies. To disable them outright, you can just run `Set-ExecutionPolicy -ExecutionPolicy Unrestricted` to allow the unsigned script to run.

### Credit

Credit to [Kanchana Wickremasinghe](https://medium.com/@kanchana.w?source=post_page-----f80b92b1c6a7--------------------------------) for his article [Kubernetes Multi-Node Cluster with Multipass on Ubuntu 18.04 Desktop](https://medium.com/platformer-blog/kubernetes-multi-node-cluster-with-multipass-on-ubuntu-18-04-desktop-f80b92b1c6a7) which was the base I created this off of.

## Troubleshooting

### remote error: tls: bad record MAC

If you end up with errors like "remote error: tls: bad record MAC" during image pull (and other activities) while using Multipass, it sounds like there may be some bugs with using WiFi with [Hyper-V](https://stackoverflow.com/a/56946337) and/or [WSL](https://github.com/microsoft/WSL/issues/4306). I resolved this by plugging in an wired connection.
