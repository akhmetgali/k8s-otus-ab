#!/bin/bash

# RUN THIS SCRIPT WITH ROOT USER
#
export WORKER_NAME=${hostname}

# CHANGE apiServerEndpoint with your master IP
# CHANGE token with your token
# CHANGE caCertHashes with your cert-hash
cat <<EOF |sudo tee /opt/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: JoinConfiguration
nodeRegistration:
  name: $WORKER_NAME
  criSocket: unix:///var/run/containerd/containerd.sock
discovery:
  bootstrapToken:
    apiServerEndpoint: "10.129.0.19:6443"
    token: "sl3fa0.3gjkxjpaagnm1i6q"
    caCertHashes: 
      - "sha256:33812715ee0cdcb3da0274463985c4ae3e94ec314d2af12a7afe90bb86e3def8"
    unsafeSkipCAVerification: false

---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd

---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
EOF

kubeadm join --config kubeadm-config.yaml

