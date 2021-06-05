# Install Kubernetes Cluster using kubeadm

Follow this documentation to set up a Kubernetes cluster on `Ubuntu 20.04 LTS`.

This documentation guides you in setting up a cluster with one master node and one worker node.

## On both Kmaster and Kworker

##### Login as root user

```bash
sudo su -
```

##### Disble Firewall

```bash
ufw disable
```

##### Disable Swap

```bash
swapoff -a; sed -i '/swap/d' /etc/fstab
```

##### Enable and Load Kernel Modules

```bash
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
```

##### Add Kernel Settings

```bash
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system
```

##### Install Containerd Runtime

```bash
apt update -qq
apt install -qq -y containerd apt-transport-https
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
```

##### Add apt repo for Kubernetes

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
```

##### Install Kubernetes components (kubeadm, kubelet and kubectl)

```bash
apt install -qq -y kubeadm kubelet kubectl
```

##### Enable ssh password authentication

```bash
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd
```

##### Set root password

```bash
echo -e "kubeadmin\nkubeadmin" | passwd root
echo "export TERM=xterm" >> /etc/bash.bashrc
```

##### Update /etc/hosts file

modified the IP to fit your case

```bash
cat >>/etc/hosts<<EOF
10.10.10.201   kmaster.example.com     kmaster
10.10.10.202   kworker1.example.com    kworker1
10.10.10.203   kworker2.example.com    kworker2
EOF
```

## Master Node ONLY

##### Pull Required Containers

```bash
kubeadm config images pull
```

##### Initialize Kubernetes Cluster

Where `10.10.10.201` is the IP address of this node

```bash
kubeadm init --apiserver-advertise-address=10.10.10.201 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

##### (Optional) Reset kubeadmin if anything goes wrong

```
kubeadm reset cleanup-node
```

##### Deploy Calico network

```bash
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/calico.yaml
```

##### Generate and Save cluster join command to /joincluser.sh

```bash
kubeadm token create --print-join-command > joincluster.sh
```

## Worker Node ONLY

##### Join the cluster

```bash
cat joincluster.sh
```

Execute the output from the command above to all the worker node

##### Set label to the worker

Execute the following command on the `Master Node`

```bash
kubectl label node <custom-label> node-role.kubernetes.io/worker=worker
```

##### Check the cluster-info and cluster status

Execute the following command on the `Master Node`

```bash
kubectl get nodes -o wide
kubectl cluster-info
```

## (Optional) Set Up Load Balancer Node

##### Install Haproxy

```bash
apt update && apt install -y haproxy
```

##### Configure Haproxy

Append the below lines to `/etc/haproxy/haproxy.cfg`

```bash
frontend kubernetes-frontend
    bind 10.10.10.200:6443
    mode tcp
    option tcplog
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    option tcp-check
    balance roundrobin
    server kmaster1 10.10.10.201:6443 check fall 3 rise 2
    server kworker1 10.10.10.202:6443 check fall 3 rise 2
```

##### Restart haproxy service

```bash
systemctl restart haproxy
```

## (Optional) Kubeadm HA | Adding Additional Nodes to the Cluster

##### IMPORTANT: REQUIRED A LOAD BALANCER NODE!!

Reference: [Stacked control plane and etcd nodes](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#stacked-control-plane-and-etcd-nodes)

##### Initialize Kubernetes Cluster (HA)

Notes:

- Assume you have already provisioned a LoadBalancer Node using HAPorxy
- You may need to reset the cluster node with `kubeadm reset cleanup-node`
- `--control-plane-endpoint` specifies the `LoadBalancer's IP`

```bash
kubeadm init --control-plane-endpoint="10.10.10.200:6443" --upload-certs --apiserver-advertise-address=10.10.10.201 --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

##### Deploy Calico Network

```bash
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/calico.yaml
```

##### Regenerate Kubeadm Token if expired

Execute the following command on the `Master Node`

```bash
kubeadm token --help | less
kubeadm token create --help
kubeadm token list
# To create a new certificate key
kubeadm init phase upload-certs --upload-certs
# Join the other node to the existing cluster (works for both the WORKER NODE and the MASTER NODE)
kubeadm token create --certificate-key <string> --print-join-command
```

##### Join other nodes to the cluster `kmaster2` & `kworker1`

Use the respective `kubeadm join` commands you copied from the output of `kubeadm token create` command on the first master node

WORKER NODE: (do not need the `--control-plan` and `--certificate-key`)

Generate and Save cluster join command to `joincluser.sh` (WORKER NODE ONLY)

```bash
kubeadm token create --print-join-command > joincluster.sh
cat joincluser.sh
```

MASTER NODE: (You also need to pass `--apiserver-advertise-address` to the join command when you join the other `master node`)

```bash
kubeadm join 10.10.10.201:6443 --token 7lvd63.pvpcrmkzhlv8qcax --discovery-token-ca-cert-hash sha256:e8afa57e3baccfac5f6f6e33d030da7e7d962072c5d3b7e3e3525ccd8f3cb2c8 --control-plane --certificate-key 12cf1dd68eec2b31b60c3779e036a049e707a7d0f52b171193f42bf1b3b51a81 --apiserver-advertise-address <IP of the current machine>
```

##### Set label to the worker

Execute the following command on the `Master Node`

```bash
kubectl label node <custom-label> node-role.kubernetes.io/worker=worker
```

## Downloading kube config to your local machine

On your host machine

```bash
mkdir ~/.kube
scp root@<target-ip>:/etc/kubernetes/admin.conf ~/.kube/config
```

## Verifying the cluster

```bash
kubectl cluster-info
kubectl get nodes
kubectl get cs
```

Enjoy!
