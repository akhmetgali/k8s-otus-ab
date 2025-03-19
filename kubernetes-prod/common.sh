#!/bin/bash

# This script must run on all nodes. Master and worker
# 
# Install CRI

# Turn on IPv4 форвардинг
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Check net.ipv4.ip_forward is set to 1
sysctl net.ipv4.ip_forward

# Install ContainerD
sudo apt-get update

cd /opt
sudo wget https://github.com/containerd/containerd/releases/download/v1.7.25/containerd-1.7.25-linux-amd64.tar.gz
sudo wget https://github.com/opencontainers/runc/releases/download/v1.2.4/runc.amd64
sudo wget https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz

sudo tar Cxzvf /usr/local containerd-1.7.25-linux-amd64.tar.gz
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.2.tgz

sudo mkdir -p /etc/containerd/
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl status containerd


# Important Note
# Make sure that cri is not included in the disabled_plugins list within /etc/containerd/config.toml; if you made changes to that file, also restart containerd.


# ######################################
# Installing kubeadm, kubelet, kubectl #
# ######################################
#
sudo swapoff -a
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Kubernetes version 1.31
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
sudo systemctl status kubelet.service

echo br_netfilter |sudo tee /etc/modules-load.d/br_netfilter.conf
systemctl status systemd-modules-load.service
