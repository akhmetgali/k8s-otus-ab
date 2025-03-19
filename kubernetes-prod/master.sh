#!/bin/bash

# ################################
# Installing master and Flannel #
# ###############################

# RUN THIS AS ROOT
sudo -i
apt install -y net-tools
export LOCAL_IP=$(ifconfig eth0 |grep inet |head -1 |awk -F" " '{print $2}')

cat <<EOF | sudo tee /opt/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  name: master
localAPIEndpoint:
  advertiseAddress: $LOCAL_IP # change to you master local ip

---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: v1.31.0
networking:
  podSubnet: "10.244.0.0/16" # --pod-network-cidr apparently special value for flannel
  serviceSubnet: "10.255.0.0/16"

---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd

---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
EOF

kubeadm init --config /opt/kubeadm-config.yaml

# On the output of kubeadm keep token and cetificate hash
# --token xxxxxxxxxxxxxxxxxxxxxxxxxx \
# --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#
# #################
# INSTALL FLANNEL #
# #################

export KUBECONFIG=/etc/kubernetes/admin.conf
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
kubectl create ns kube-flannel
kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged
helm repo add flannel https://flannel-io.github.io/flannel/
helm install flannel --set podCidr="10.244.0.0/16" --namespace kube-flannel flannel/flannel

echo $LOCAL_IP | tee /opt/master-localIp
