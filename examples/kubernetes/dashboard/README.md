# Kubernetes Dashboard

## Commands

#### Deploy the Kubernetes Dashboard on the new cluster

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml
```

#### Create the service account and the cluster-role-binding in the cluster

```bash
$ kubectl apply -f oke-admin-service-account.yaml
```

#### Obtain an authentication token for the oke-admin service account

```bash
$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin |
awk '{print $1}')
```

#### Access the dashboard

```bash
$ kubectl proxy
```

#### (Alternatives) access the dashboard with nodeport

```bash
$ kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":8443,"nodePort":30443}]}}'
```

#### (Optional) Expose your Kubernetes Dashboard using a LoadBalancer

```bash
$ kubectl apply -f k8s-dashboard-loadbalancer.yaml
$ kubectl -n kube-system get svc
```

This file defines a `LoadBalancer` exposing port `8443` from the Kubernetes dashboard with an allocated IP address on port `443`

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard-lb
  namespace: kube-system
spec:
  type: LoadBalancer
  ports:
    - port: 443
      protocol: TCP
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
```
