# Kubernetes Dashboard

## Commands

#### Deploy the Kubernetes Dashboard on the new cluster

```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml
```

#### Create the service account and the cluster-role-binding in the cluster

```
$ kubectl apply -f oke-admin-service-account.yaml
```

#### Obtain an authentication token for the oke-admin service account

```
$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin |
awk '{print $1}')
```

#### Access the dashboard

```
$ kubectl proxy
```

#### (Alternatives) access the dashboard with nodeport

```
$ kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":8443,"nodePort":30443}]}}'
```
