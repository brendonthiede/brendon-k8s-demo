# Ansible Notes

## Warning

This is not currently working!!!

There were a couple bugs with this solution that caused me to go with the previous strategy, but this may be the simpler approach once the kinks are worked out, especially for upgrading your Kubernetes version.

In order to try this solution, you will need to use WSL2 in order to run Ansible.

1. Install [Virtual Box 6.1](https://www.virtualbox.org/wiki/Downloads) or newer (Hyper-V compatability).
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
4. Replace Vagrantfile with Vagrantfile-ansible in the multi-node directory.
5. Run the following from a WSL Bash prompt to create and intialize the cluster (you will likely need to approve several prompts to give VirtualBox the rights it needs to getting things rolling, at least the first time):
```bash
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
cd ./multi-node/kubeadm/
vagrant up
```
