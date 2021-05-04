# Istio Deployment

![](https://cilium.io/static/a4714968170f5d9eb1258371694f343f/29f4e/istio.png)

## Introduction to Istio

[Istio](https://istio.io/latest/) is an open platform that provides a uniform way to connect, manage, and secure microservices. Istio supports managing traffic flows between microservices, enforcing access policies, and aggregating telemetry data, all without requiring changes to the microservice code. Istio gives you:

- Automatic load balancing for HTTP, gRPC, WebSocket, and TCP traffic.
- Fine-grained control of traffic behavior with rich routing rules, retries, failovers, and fault injection.
- A pluggable policy layer and configuration API supporting access controls, rate limits and quotas.
- Automatic metrics, logs, and traces for all traffic within a cluster, including cluster ingress and egress.
- Secure service-to-service communication in a cluster with strong identity-based authentication and authorization.”

## Istio Architecture

<img src="https://images.ctfassets.net/22g1lenhck4z/6zExa15ODWXaYk7x9LtEJv/a8262fbcb978f64a0456001262dca56f/1__pYrG7dF5AP9eHCa4YuTFgw.png" width="600" height="500"/>

## Prerequisites

- Install [kubectl](https://kubernetes.io/docs/tasks/tools/) on your local machine
- Install [Helm](https://helm.sh/) on your local machine
- Do a quick upgrade of Tiller (just to be sure you are on the latest release) --> `$ helm init --upgrade`
- A working Cluster --> Using [Oracle Kubernetes Engine](https://www.googleadservices.com/pagead/aclk?sa=L&ai=DChcSEwii1u70yq_wAhU1Hq0GHRb9AaEYABACGgJwdg&ohost=www.google.com&cid=CAESQeD2n7sZzsajGfZoCfP4Qbor81BJm-Qob3xvyooB8kZpSGOQOS1Z2IcsOa2aY-lov5GdpKiZe6jMhEDpTaNznNbl&sig=AOD64_0rIbTkjOs0F0FvhNsGWA7LBeFvzg&q&adurl&ved=2ahUKEwiHzOb0yq_wAhWMEDQIHechA94Q0Qx6BAgDEAE) below for demo purposes

## Install Steps

### Install Istio CLI Release

```bash
$ curl -L https://git.io/getLatestIstio | sh -
```

### Install Istio with Helm

1. Create a namespace `istio-system` for Istio components

```bash
$ kubectl create namespace `istio-system`
```

2. Install the Istio base chart which contains cluster-wide resources used by the Istio control plane

```bash
$ helm install istio-base manifests/charts/base -n istio-system
```

3. Install the Istio discovery chart which deploys the `istiod service`

```bash
$ helm install istiod manifests/charts/istio-control/istio-discovery \
    -n istio-system
```

4. (Optional) Install the Istio ingress gateway chart which contains the ingress gateway components

```bash
$ helm install istio-ingress manifests/charts/gateways/istio-ingress \
    -n istio-system
```

5. (Optional) Install the Istio egress gateway chart which contains the egress gateway components

```bash
$ helm install istio-egress manifests/charts/gateways/istio-egress \
    -n istio-system
```

## Verifying the installation

Ensure all Kubernetes pods in `istio-system` namespace are deployed and have a `STATUS` of `Running`

```bash
$ kubectl get pods -n istio-system
```

## Configure Sidecar Injection

In order to have `sidecar injection` at deployment you must enable the `namespace` for your application. To enable the `namespace` for `automatic injection` execute the following command:

```bash
$ kubectl label namespace default istio-injection=enabled
```

## Deploy Sample Application

### Application Architecture

![](https://istio.io/latest/docs/examples/bookinfo/withistio.svg)

### Deployment Steps

1. Change directory to the root of the Istio installation.

2. The default Istio installation uses `automatic sidecar injection`. Label the namespace that will host the application with `istio-injection=enabled`

3. Deploy your application using the kubectl command

```bash
$ kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```

4. Confirm all services and pods are correctly defined and running

```bash
$ kubectl get services
NAME          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.0.0.31    <none>        9080/TCP   6m
kubernetes    ClusterIP   10.0.0.1     <none>        443/TCP    7d
productpage   ClusterIP   10.0.0.120   <none>        9080/TCP   6m
ratings       ClusterIP   10.0.0.15    <none>        9080/TCP   6m
reviews       ClusterIP   10.0.0.170   <none>        9080/TCP   6m
```

and

```bash
$ kubectl get pods
NAME                             READY     STATUS    RESTARTS   AGE
details-v1-1520924117-48z17      2/2       Running   0          6m
productpage-v1-560495357-jk1lz   2/2       Running   0          6m
ratings-v1-734492171-rnr5l       2/2       Running   0          6m
reviews-v1-874083890-f0qf0       2/2       Running   0          6m
reviews-v2-1343845940-b34q5      2/2       Running   0          6m
reviews-v3-1813607990-8ch52      2/2       Running   0          6m
```

5. To confirm that the Bookinfo application is running, send a request to it by a `curl` command from some pod, for example from `ratings`

```bash
$ kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
<title>Simple Bookstore App</title>
```

### Determine the ingress IP and port

Now that the Bookinfo services are up and running, you need to make the application accessible from outside of your Kubernetes cluster, e.g., from a browser. An [Istio Gateway](https://istio.io/latest/docs/concepts/traffic-management/#gateways) is used for this purpose

1. Define the ingress gateway for the application

```bash
$ kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
```

2. Confirm the gateway has been created

```bash
$ kubectl get gateway
NAME               AGE
bookinfo-gateway   32s
```

3. Set the `INGRESS_HOST` and `INGRESS_PORT` variables for accessing the gateway

Setup with external loadbalancer

```bash
$ export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
$ export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
$ export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
$ export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')
```

4. Set GATEWAY_URL

```bash
$ export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
$ echo $GATEWAY_URL
```

### Confirm the app is accessible from outside the cluster

To confirm that the Bookinfo application is accessible from outside the cluster, run the following `curl` command

```bash
$ curl -s "http://${GATEWAY_URL}/productpage" | grep -o "<title>.*</title>"
<title>Simple Bookstore App</title>
```

You can also point your browser to `http://$GATEWAY_URL/productpage` to view the Bookinfo web page. If you refresh the page several times, you should see different versions of reviews shown in `productpage`, presented in a round robin style (red stars, black stars, no stars), since we haven’t yet used Istio to control the version routing

### Cleanup

When you’re finished experimenting with the Bookinfo sample, uninstall and clean it up using the following instructions:

1. Delete the routing rules and terminate the application pods

```bash
$ samples/bookinfo/platform/kube/cleanup.sh
```

2. Confirm shutdown

```bash
$ kubectl get virtualservices   #-- there should be no virtual services
$ kubectl get destinationrules  #-- there should be no destination rules
$ kubectl get gateway           #-- there should be no gateway
$ kubectl get pods              #-- the Bookinfo pods should be deleted
```

## Reference

- [Deploying the Istio Service Mesh on OKE](https://www.ateam-oracle.com/istio-on-oke)
- [Install Istio with Helm](https://istio.io/latest/docs/setup/install/helm/)
- [Istio Ingress Gateway](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/#determining-the-ingress-ip-and-ports)
- [Istio Bookinfo Application](https://istio.io/latest/docs/examples/bookinfo/)
- [Grafana Plugin Integration](https://istio.io/latest/docs/ops/integrations/grafana/)
