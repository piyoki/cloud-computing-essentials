# Oracle Functions Demo

## Architecture

![](https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/functions/func-api-gtw/images/oracle-funcs-api-gtw-diagram.png)

## Setup Process

- [Creating & Deploying Functions](https://docs.oracle.com/en-us/iaas/Content/Functions/Tasks/functionsuploading.htm)
- [Policy Rule Setup](https://docs.oracle.com/en-us/iaas/Content/APIGateway/Tasks/apigatewaycreatingpolicies.htm)
- [VCN Setup & API Gateway Mapping](https://docs.oracle.com/en-us/iaas/Content/APIGateway/Tasks/apigatewaycreatingpolicies.htm)
- [(Overview) Functions: Call a Function using API Gateway](https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/functions/func-api-gtw/01-summary.htm)

## Useful Commands

### Fn Project CLI

```
$ curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install | sh
```

### Deploy

```
# Configuration and Quick Deployment

$ fn create context <my-context> --provider oracle
$ fn use context <my-context>
$ fn update context oracle.compartment-id <compartment-ocid>
$ fn update context api-url <api-endpoint>
$ fn update context registry <region-key>.ocir.io/<tenancy-namespace>/<repo-name>
$ fn update context oracle.profile <profile-name>
$ fn create app <app-name> --annotation oracle.com/oci/subnetIds='["<subnet-ocid>"]'
$ fn deploy -v --app <app-name>

# Custom Dockfile Deployment

$ fn init --runtime <runtime option> <app-name>
$ fn build # alternatives
$ fn deploy -v --app <app-name>
$ fn inspect function <app-name> <fn-name>
$ fn invoke <app-name> <fn-name>
```

### Invoke

#### Fn CLI

```
$ fn invoke helloworld-app helloworld-func
```

#### Oracle Cloud CLI

```
$ oci raw-request --http-method POST --target-uri <Function URL> --profile <OCI Profile>

```

#### API Gateway ONLY

```

```
