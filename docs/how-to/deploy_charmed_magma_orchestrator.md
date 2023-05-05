# Deploy Charmed Magma Orchestrator

## Requirements

The Orchestrator must be installed on a Kubernetes cluster with the following specifications:

- **Kubernetes**: A cluster with a total of a minimum of 6 vCPUs and 16 GB of RAM.
- **Juju 2.9**: A Juju controller with access to the Kubernetes cluster

```{note}
If the Juju controller is running on your Kubernetes cluster, it should use a LoadBalancer service type.
```

## Deploy the magma-orc8r bundle

Create an `overlay.yaml` file that contains the following content:

```{code-block} yaml
:caption: overlay.yaml
applications:
  fluentd:
    options:
      domain: <your domain name>
      elasticsearch-url: <your elasticsearch https url>
  orc8r-certifier:
    options:
      domain: <your domain name>
  orc8r-eventd:
    options:
      elasticsearch-url: <your elasticsearch http url>
  orc8r-nginx:
    options:
      domain: <your domain name>
  tls-certificates-operator:
    options:
      generate-self-signed-certificates: true
      ca-common-name: rootca.<your domain name>
```

```{warning}
This configuration is unsecure because it uses self-signed certificates.
```

```{note}
Elasticsearch is not part of the magma-orc8r bundle and needs to be deployed separately. For details regarding Elasticsearch integration please visit [Integrate Charmed Magma Orchestrator to Elasticsearch](integrate_charmed_magma_orchestrator_to_elasticsearch.md)
```

Deploy Orchestrator:

```{code-block} shell
juju deploy magma-orc8r --overlay overlay.yaml --trust --channel=1.8/stable
```

The deployment is completed when all services are in the `Active-Idle` state.

## Setup DNS

Retrieve the services that need to be exposed:

```{code-block} shell
juju run-action orc8r-orchestrator/leader get-load-balancer-services --wait
```

In your domain registrar, create DNS records for the following Kubernetes services:

| Address                                | Hostname                                | 
|----------------------------------------|-----------------------------------------|
| `<orc8r-bootstrap-nginx External IP>`  | `bootstrapper-controller.<your domain>` | 
| `<orc8r-nginx-proxy External IP>`      | `api.<your domain>`                     | 
| `<orc8r-clientcert-nginx External IP>` | `controller.<your domain>`              | 
| `<nginx-proxy External IP>`            | `*.nms.<your domain>`                   | 
| `<fluentd External IP>`                | `fluentd.<your domain>`                 | 

## Verify the deployment

Get the host organization's username and password:

```{code-block} shell
juju run-action nms-magmalte/leader get-host-admin-credentials --wait
```

Confirm successful deployment by visiting `https://host.nms.<your domain>` and logging in with the `admin-username` and `admin-password` outputted here.
