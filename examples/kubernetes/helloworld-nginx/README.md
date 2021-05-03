# Hellowold Nginx Deployment

## Prerequisites

- Make sure you have set up [OKE Cluster](https://enabling-cloud.github.io/oci-learning/manual/OracleContainerEngineForKubernetes.html)
- Make sure you have pushed `helloworld-nginx` Image to [OCI Registry](https://enabling-cloud.github.io/oci-learning/manual/OCIRegistry.html)

## Create Kubernetes Seceret

```bash
$ kubectl create secret docker-registry ocirsecret --docker-server=<region-code>.ocir.io --docker-username='<tenancy-name>/<oci-username>' --docker-password='<oci-auth-token>' --docker-email='<email-address>'

$ kubectl get secrets
```

## Pull Source Image and Push to OCI Registry

```bash
# pull original image from Docker Hub
$ docker pull hikariai/helloworld-nginx:latest

# Tag the image and push it to OCI Registry
$ docker tag hikariai/helloworld-nginx:latest {region-code}.ocir.io/{tenancy-name}/{repo-name}/{image-name}:{tag}
```

## Deploy Kubernetes Application

```bash
# Edit and modify the Image associated with the OCI Registry
$ vim helloworld-lb.yaml

# Deploy
$ kubectl apply -f helloworld-lb.yaml

# Observe
$ kubectl get deployments
$ kubectl get pods -o wide
$ kubectl get svc
```

**Note:** `OCI Loadbalancer` would be automatically created.

![](https://github.com/yqlbu/cloud-computing-essentials/blob/master/examples/kubernetes/helloworld-nginx/demoshot_1.png?raw=true)

Access the application with external ip address

![](https://github.com/yqlbu/cloud-computing-essentials/blob/master/examples/kubernetes/helloworld-nginx/demoshot_2.png?raw=true)

## Clean Up

```bash
$ kubectl delete deployment helloworld-nginx-deployment
$ kubectl delete service helloworld-nginx-service
```
