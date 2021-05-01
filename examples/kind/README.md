# Kind (required docker)

```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
sudo chmod u+x kind && sudo mv kind /usr/bin/kind
kind create cluster --name kind-baremetal
kind get clusters
kubectl cluster-info --context kind-kind-baremetal
```

## deleting a cluster

```
unset KUBECONFIG
kind delete clusters kind-baremetal
```

## custom multiple nodes cluster

```
curl -fsSL https://raw.githubusercontent.com/kubernetes-sigs/kind/master/site/content/docs/user/kind-example-config.yaml -o ~/.kube/kind-example-config.yaml
kind create cluster --config kind-example-config.yaml --name kind-baremetal
kind delete cluster
```
