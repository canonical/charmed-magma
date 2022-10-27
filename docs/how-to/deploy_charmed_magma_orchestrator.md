# Deploy Charmed Magma Orchestrator

## Requirements

The Access Gateway must be installed on a Kubernetes cluster with the following specifications:

- **:material-kubernetes: Kubernetes**: A cluster with a minimum of 3 Nodes with 2 vCPUs and 8 GB of RAM each.

## Deploy the magma-orc8r bundle

From your Ubuntu machine, create an `overlay.yaml` file that contains the following content:

```yaml
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
juju run-action orc8r-certifier/leader get-pfx-package-password --wait
```

!!! info

    The pfx package was copied to your current working directory. It can now be loaded in your browser or used
    to make API calls to Magma orchestrator.

## Setup DNS

Retrieve the services that need to be exposed:

```bash
juju run-action orc8r-orchestrator/leader get-load-balancer-services --wait
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
juju run-action nms-magmalte/leader get-master-admin-credentials --wait
```

Confirm successful deployment by visiting `https://master.nms.<your domain>` and logging in
with the `admin-username` and `admin-password` outputted here.
