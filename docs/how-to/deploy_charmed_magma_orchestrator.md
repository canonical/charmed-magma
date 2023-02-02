# Deploy Charmed Magma Orchestrator

## Requirements

The Orchestrator must be installed on a Kubernetes cluster with the following specifications:

- **:material-kubernetes: Kubernetes**: A cluster with a total of a minimum of 6 vCPUs and 16 GB of RAM.
- **:material-ubuntu: Juju>=3**: A Juju controller with access to the Kubernetes cluster

!!! note

    If the Juju controller is running on your Kubernetes cluster, it should use a LoadBalancer
    service type

## Deploy the magma-orc8r bundle

Create an `overlay.yaml` file that contains the following content:

```yaml title="overlay.yaml"
applications:
  orc8r-certifier:
    options:
      domain: <your domain name>
  orc8r-nginx:
    options:
      domain: <your domain name>
  tls-certificates-operator:
    options:
      generate-self-signed-certificates: true
      ca-common-name: rootca.<your domain name>
```

!!! warning

    This configuration is unsecure because it uses self-signed certificates.

Deploy Orchestrator:

```bash
juju deploy magma-orc8r --overlay overlay.yaml --trust --channel=beta
```

The deployment is completed when all services are in the `Active-Idle` state.

## Import the admin operator HTTPS certificate

Retrieve the PFX package that contains the certificates to authenticate against Magma Orchestrator:

```bash
juju scp --container="magma-orc8r-certifier" orc8r-certifier/0:/var/opt/magma/certs/admin_operator.pfx admin_operator.pfx
```

Retrieve the pfx package password:

```bash
juju run orc8r-certifier/leader get-pfx-package-password
```

!!! info

    The pfx package was copied to your current working directory. It can now be loaded in your browser or used
    to make API calls to Magma orchestrator.

## Setup DNS

Retrieve the services that need to be exposed:

```bash
juju run orc8r-orchestrator/leader get-load-balancer-services
```

In your domain registrar, create A records for the following Kubernetes services:

| Address                                | Hostname                                | 
|----------------------------------------|-----------------------------------------|
| `<orc8r-bootstrap-nginx External IP>`  | `bootstrapper-controller.<your domain>` | 
| `<orc8r-nginx-proxy External IP>`      | `api.<your domain>`                     | 
| `<orc8r-clientcert-nginx External IP>` | `controller.<your domain>`              | 
| `<nginx-proxy External IP>`            | `*.nms.<your domain>`                   | 

## Verify the deployment

Get the master organization's username and password:

```bash
juju run nms-magmalte/leader get-master-admin-credentials
```

Confirm successful deployment by visiting `https://master.nms.<your domain>` and logging in
with the `admin-username` and `admin-password` outputted here.