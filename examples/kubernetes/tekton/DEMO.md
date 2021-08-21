# Complex Tekton Pipeline Demo

## Preparation

```bash
export REGISTRY_SERVER=https://index.docker.io/v1/

# Replace `[...]` with the registry username
export REGISTRY_USER=[...]

# Replace `[...]` with the registry password
export REGISTRY_PASS=[...]

# Replace `[...]` with the registry email
export REGISTRY_EMAIL=[...]

kubectl create namespace tekton-builds

kubectl --namespace tekton-builds \
    create secret \
    docker-registry regcred \
    --docker-server=$REGISTRY_SERVER \
    --docker-username=$REGISTRY_USER \
    --docker-password=$REGISTRY_PASS \
    --docker-email=$REGISTRY_EMAIL

# Create Namespace
kubectl create namespace staging

kubectl create namespace production
```

## Tekton Pipeline Definition

```bash
cat cd.yaml

kubectl apply -f pipeline.yml

kubectl --namespace tekton-builds \
    get pipelines
```

## Tekton Pipeline Run

```bash
tkn --namespace tekton-builds \
    pipeline start littlelink-server-pipeline \
    --dry-run

cat pipeline-run.yaml

kubectl create --filename cd-run.yaml

tkn --namespace tekton-builds \
    pipelinerun list

tkn --namespace tekton-builds \
    pipelinerun logs --last --follow

kubectl --namespace tekton-builds \
    get pods
```

## Tekton Hub

visit https://hub.tekton.dev/
