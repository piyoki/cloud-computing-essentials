# Tekton Pipelines

## Installation

### Install the CLI

Install `tkn` by following the instructions from `the Set up the CLI` section in https://tekton.dev/docs/getting-started/

### Deploy Tekton Operator into Kubernetes Cluster

Notes: You will need an `ingress-controller` of your type for `Tekton` to be exposed outside of the cluster

```bash
# namespace
kubectl create namespace tekton-pipelines

# pipeline
kubectl apply \
    --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# triggers
kubectl apply \
    --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# dashboard
kubectl apply \
    --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
```

#### Persistent Volumes

To run a CI/CD workflow, you need to provide Tekton a Persistent Volume for storage purposes. Tekton requests a volume of 5Gi with the default storage class by default.

If you would like to configure the size and storage class of the Persistent Volume Tekton requests, update the default config-artifact-pvc configMap. This configMap includes two attributes:

- `size`: the size of the volume
- `storageClassName`: the name of the storage class of the volume

The following example asks Tekton to request a Persistent Volume of `5Gi` with the `manual` storage class when running a workflow:

```bash
kubectl create configmap config-artifact-pvc \
                         --from-literal=size=5Gi \
                         --from-literal=storageClassName=longhorn \
                         -o yaml -n tekton-pipelines \
                         --dry-run=client | kubectl replace -f -
```

### CI/CD workflow with Tekton Demo

To create a `Task`, create a Kubernetes object using the Tekton API with the kind `Task`. The following YAML file specifies a `Task` with one simple `Step`, which prints a `Hello World!` message using the `official Ubuntu image`:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: hello
spec:
  steps:
    - name: hello
      image: ubuntu
      command:
        - echo
      args:
        - "Hello World!"
EOF
```

To run this task with Tekton, you need to create a `TaskRun`, which is another Kubernetes object used to specify run time information for a `Task`.

```bash
tkn task start hello --dry-run
```

To use the `TaskRun` above to start the `echo Task`, you can either use `tkn` or `kubectl`

Start with `tkn`:

```bash
tkn task start hello
```

Start with `kubectl`:

```bash
# use tkn's --dry-run option to save the TaskRun to a file
tkn task start hello --dry-run > taskRun-hello.yaml

# create the TaskRun
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: hello-run-
spec:
  taskRef:
    name: hello
EOF
```

Tekton will now start running your `Task`. To see the logs of the last `TaskRun`, run the following `tkn` command:

```bash
tkn taskrun logs --last -f
```

It may take a few moments before your `Task` completes. When it executes, it should show the following output:

```bash
[hello] Hello World!
```
