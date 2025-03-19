#!/bin/bash

# RUN ALL COMMANDS AS ROOT USER

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt list --upgradable
apt-cache rdepends --installed kubernetes-cni
apt-mark unhold kubeadm
apt install -y kubeadm
apt-mark hold kubeadm

export NODE_NAME=$(hostname)
kubeadm upgrade node
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl drain $NODE_NAME --ignore-daemonsets
apt-mark unhold kubelet kubectl && apt-get update && sudo apt-get install -y kubelet kubectl && apt-mark hold kubelet kubectl
systemctl daemon-reload
systemctl restart kubelet
kubectl uncordon $NODE_NAME

