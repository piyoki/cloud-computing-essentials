# Kubernetes Dashboard

## Steps

#### Deploy the Kubernetes Dashboard on the new cluster

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```

#### Create the service account and the cluster-role-binding in the cluster

declarative way

```
$ kubectl create serviceaccount dashboard-admin -n kube-system
$ kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
```

manifest way

```bash
$ cat << EOF > oke-admin-service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: oke-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: oke-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: oke-admin
    namespace: kube-system
EOF
```

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

The output from the above command includes an authentication token (a long alphanumeric string) as the value of the `token`: element

visit `https://IP:30443` to start using the dashboard

#### (Optional) Expose your Kubernetes Dashboard using a LoadBalancer

```bash
$ kubectl apply -f k8s-dashboard-loadbalancer.yaml
```

This file defines a `LoadBalancer` exposing port `8443` from the Kubernetes dashboard with an allocated IP address on port `443`

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard-lb
  namespace: kubernetes-dashboard
spec:
  type: LoadBalancer
  ports:
    - port: 443
      protocol: TCP
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
```

Wait a few seconds until an IP address is ready to serve traffic on port `443`:

```bash
$ kubectl -n kube-system get svc
NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
heapster                        ClusterIP      10.100.200.91    <none>        8443/TCP        30d
kube-dns                        ClusterIP      10.100.200.2     <none>        53/UDP,53/TCP   30d
kubernetes-dashboard            NodePort       10.100.200.149   <none>        443:32283/TCP   30d
kubernetes-dashboard-lb         LoadBalancer   10.100.200.138   1.2.3.4       443:30006/TCP   7m38s
metrics-server                  ClusterIP      10.100.200.205   <none>        443/TCP         30d
monitoring-influxdb             ClusterIP      10.100.200.253   <none>        8086/TCP        30d
```

Look at entry `kubernetes-dashboard-lb` to find the IP address to use.

Demoshot

![](https://github.com/yqlbu/cloud-computing-essentials/blob/master/examples/kubernetes/dashboard/dashboard.png)
