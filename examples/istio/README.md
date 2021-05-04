# Istio Deployment

## Introduction to Istio

Istio is an open platform that provides a uniform way to connect, manage, and secure microservices. Istio supports managing traffic flows between microservices, enforcing access policies, and aggregating telemetry data, all without requiring changes to the microservice code. Istio gives you:

- Automatic load balancing for HTTP, gRPC, WebSocket, and TCP traffic.
- Fine-grained control of traffic behavior with rich routing rules, retries, failovers, and fault injection.
- A pluggable policy layer and configuration API supporting access controls, rate limits and quotas.
- Automatic metrics, logs, and traces for all traffic within a cluster, including cluster ingress and egress.
- Secure service-to-service communication in a cluster with strong identity-based authentication and authorization.”

## Prerequisites

- Install [kubectl](https://kubernetes.io/docs/tasks/tools/) on your local machine
- Install [Helm](https://helm.sh/) on your local machine
- Do a quick upgrade of Tiller (just to be sure you are on the latest release) --> `$ helm init --upgrade`
- A working Cluster --> Using [Oracle Kubernetes Engine](https://www.googleadservices.com/pagead/aclk?sa=L&ai=DChcSEwii1u70yq_wAhU1Hq0GHRb9AaEYABACGgJwdg&ohost=www.google.com&cid=CAESQeD2n7sZzsajGfZoCfP4Qbor81BJm-Qob3xvyooB8kZpSGOQOS1Z2IcsOa2aY-lov5GdpKiZe6jMhEDpTaNznNbl&sig=AOD64_0rIbTkjOs0F0FvhNsGWA7LBeFvzg&q&adurl&ved=2ahUKEwiHzOb0yq_wAhWMEDQIHechA94Q0Qx6BAgDEAE) below for demo purposes

## Install Istio

### Install Istio CLI

```bash
$ curl -L https://git.io/getLatestIstio | sh -
```

### Configuring parameters before the installation

Prior to performing the installation, let’s make some changes to the Istio `values.yaml` file. The `values.yaml` file informs Helm which components to install on the OKE platform. The `values.yaml` file is located at `/<istio installation directory>/install/kubernetes/helm/istio`

In order to have the components `Grafana`, `Prometheus`, `Servicegraph`, and `Jaeger` deployed, the `values.yaml` file needs to be modified. For each of the components you want deployed, change the enabled property from `false` to `true`.

```yaml
Servicegraph:
enabled: true
replicaCount: 1
image: servicegraph
service:
  name: http
  type: ClusterIP
  externalPort: 8088
  internalPort: 8088
```

### Install Istio with Helm

```bash
$ helm install install/kubernetes/helm/istio --name istio --namespace istio-system
```

Notes:

The helm install command will configure your cluster to do automatic sidecar injection. In fact, automatic sidecar injection is the default. To verify that your istio installation was successful execute the kubectl command and ensure you have the following containers deployed to your cluster.

Since the “values.yaml” was modified to enable the deployment of Grafana, Prometheus, ServiceGraph, and Jeager you will see those components deployed as well.

```bash
$ kubectl get pods -n istio-system
```

## Configure Sidecar Injection

In order to have `sidecar injection` at deployment you must enable the `namespace` for your application. To enable the `namespace` for `automatic injection` execute the following command:

```bash
$ kubectl label namespace default istio-injection=enabled
```

## Reference

[Deploying the Istio Service Mesh on OKE](https://www.ateam-oracle.com/istio-on-oke)
