#!/bin/bash

K8S_VERSION=1.11.3-00
node_type=master

apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

apt-mark hold kubelet kubeadm kubectl

#Initialize the k8s cluster
kubeadm init --pod-network-cidr=10.244.0.0/16

sleep 60

#Create .kube file if it does not exists
mkdir -p $HOME/.kube

#Move Kubernetes config file if it exists
if [ -f $HOME/.kube/config ]; then
    mv $HOME/.kube/config $HOME/.kube/config.back
fi

sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#if you are using a single node which acts as both a master and a worker
#untaint the node so that pods will get scheduled:
kubectl taint nodes --all node-role.kubernetes.io/master-

#Install Flannel network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

echo "Done."
