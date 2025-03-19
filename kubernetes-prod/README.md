# Kubernetes Installation with kubeadm

## Configuration

You need to create VMs with ubuntu 24.04
CPU 2
RAM 8 GB

1 master node
3 worker nodes

## Installation

1. run `common.sh` script on each node. master and workers
2. run `master.sh` script on master node
3. keep master local ip, token and cert-hash from master node.
4. edit `worker.sh` sript. Change apiServerEndpoint with your master local ip, token with your token and caCertHashes with your cert-hash
5. run `worker.sh` on each worker node
6. login back to master node
7. login as root
8. run `export KUBECONFIG=/etc/kubernetes/admin.conf`
9. check your cluster `kubectl get nodes`
10. check your pod `kubectl get po -A`


```
NAMESPACE      NAME                             READY   STATUS    RESTARTS        AGE
kube-flannel   kube-flannel-ds-llrvk            1/1     Running   4 (3m52s ago)   6m13s
kube-system    coredns-7c65d6cfc9-nv6ml         1/1     Running   0               13m
kube-system    coredns-7c65d6cfc9-rz7xv         1/1     Running   0               13m
kube-system    etcd-master                      1/1     Running   0               13m
kube-system    kube-apiserver-master            1/1     Running   0               13m
kube-system    kube-controller-manager-master   1/1     Running   0               13m
kube-system    kube-proxy-hvh2d                 1/1     Running   0               13m
kube-system    kube-scheduler-master            1/1     Running   0               13m
```

## Upgrade

1. Copy file `/etc/kubernetes/admin.conf` from master to each worker node
2. run `upgrade_master.sh` on master node
3. run `uprgrade_worker.sh` on each worker node
4. check your cluster with `kubectl get no -o wide`
