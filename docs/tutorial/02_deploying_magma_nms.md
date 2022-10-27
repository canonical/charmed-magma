# 2. Deploying Magma's network management software

## Bootstrapping a Juju controller

Bootstrap a Juju controller on the Kubernetes instance we just created:

```bash
ubuntu@host:~$ juju add-k8s magma-orchestrator-k8s --client
ubuntu@host:~$ juju bootstrap magma-orchestrator-k8s
ubuntu@host:~$ juju add-model magma-orchestrator
```

## Deploying Magma Orchestrator

From your Ubuntu machine, create an `overlay.yaml` file that contains the following content:

```yaml
applications:
  orc8r-certifier:
    options:
      domain: awesome.com
  orc8r-nginx:
    options:
      domain: awesome.com
  tls-certificates-operator:
    options:
      generate-self-signed-certificates: true
      ca-common-name: rootca.awesome.com
```

Deploy Magma Orchestrator:

```bash
ubuntu@host:~$ juju deploy magma-orc8r --overlay overlay.yaml --trust --channel=beta
```

You can see the deployment's status by running `juju status`. The deployment is completed when 
all units are in the `Active-Idle` state.


!!! info

    This step can take a lot of time, expect at least 10-15 minutes.

```bash
ubuntu@host:~$ juju status
Model               Controller                          Cloud/Region                        Version  SLA          Timestamp
magma-orchestrator  magma-orchestrator-k8s-localhost  magma-orchestrator-k8s/localhost  2.9.35   unsupported  18:19:48-04:00

[...]

Unit                              Workload  Agent  Address      Ports     Message
nms-magmalte/0*                   active    idle   10.1.50.73             
nms-nginx-proxy/0*                active    idle   10.1.50.75             
orc8r-accessd/0*                  active    idle   10.1.50.76             
orc8r-alertmanager-configurer/0*  active    idle   10.1.50.81             
orc8r-alertmanager/0*             active    idle   10.1.50.77             
orc8r-analytics/0*                active    idle   10.1.50.82             
orc8r-bootstrapper/0*             active    idle   10.1.50.84             
orc8r-certifier/0*                active    idle   10.1.50.87             
orc8r-configurator/0*             active    idle   10.1.50.88             
orc8r-ctraced/0*                  active    idle   10.1.50.89             
orc8r-device/0*                   active    idle   10.1.50.90             
orc8r-directoryd/0*               active    idle   10.1.50.91             
orc8r-dispatcher/0*               active    idle   10.1.50.92             
orc8r-eventd/0*                   active    idle   10.1.50.94             
orc8r-ha/0*                       active    idle   10.1.50.95             
orc8r-lte/0*                      active    idle   10.1.50.97             
orc8r-metricsd/0*                 active    idle   10.1.50.99             
orc8r-nginx/0*                    active    idle   10.1.50.102            
orc8r-obsidian/0*                 active    idle   10.1.50.103            
orc8r-orchestrator/0*             active    idle   10.1.50.106            
orc8r-policydb/0*                 active    idle   10.1.50.107            
orc8r-prometheus-cache/0*         active    idle   10.1.50.110            
orc8r-prometheus-configurer/0*    active    idle   10.1.50.116            
orc8r-prometheus/0*               active    idle   10.1.50.72             
orc8r-service-registry/0*         active    idle   10.1.50.111            
orc8r-smsd/0*                     active    idle   10.1.50.112            
orc8r-state/0*                    active    idle   10.1.50.115            
orc8r-streamer/0*                 active    idle   10.1.50.117            
orc8r-subscriberdb-cache/0*       active    idle   10.1.50.119            
orc8r-subscriberdb/0*             active    idle   10.1.50.118            
orc8r-tenants/0*                  active    idle   10.1.50.120            
orc8r-user-grafana/0*             active    idle   10.1.50.123            
postgresql-k8s/0*                 active    idle   10.1.50.126  5432/TCP  Pod configured
tls-certificates-operator/0*      active    idle   10.1.50.121            
```

## Getting Access to Magma Orchestrator

Retrieve the PFX package and password that contains the certificates to authenticate against 
Magma Orchestrator:

```bash
ubuntu@host:~$ juju scp --container="magma-orc8r-certifier" orc8r-certifier/0:/var/opt/magma/certs/admin_operator.pfx admin_operator.pfx
ubuntu@host:~$ juju run-action orc8r-certifier/leader get-pfx-package-password --wait
```

The pfx package was copied to your current working directory. If you are using Google Chrome, 
navigate to `chrome://settings/certificates?search=https`, click on Import, select 
the `admin_operator.pfx` package that we just copied and write in the password that you received.

> **SHOW PICTURE OF HOW THIS IS LOADED IN GOOGLE CHROME**  # TODO

## Setupping DNS

Retrieve the list of services that need to be exposed:

```bash
ubuntu@host:~$ juju run-action orc8r-orchestrator/leader get-load-balancer-services --wait
```

In your host, create A records for the following Kubernetes services:  # TODO (and also must be added to agw)

| Address                                | Hostname                              | 
|----------------------------------------|---------------------------------------|
| `<orc8r-bootstrap-nginx External IP>`  | `bootstrapper-controller.awesome.com` | 
| `<orc8r-nginx-proxy External IP>`      | `api.awesome.com`                     | 
| `<orc8r-clientcert-nginx External IP>` | `controller.awesome.com`              | 
| `<nginx-proxy External IP>`            | `*.nms.awesome.com`                   | 

## Offer an application endpoint

Offer an application endpoint that we will use later for our network core to 
relate to our orchestrator:

```bash
ubuntu@host:~$ juju offer orc8r-nginx:orchestrator
```

## Verify the deployment

Get the master organization's username and password:

```bash
ubuntu@host:~$ juju run-action nms-magmalte/leader get-master-admin-credentials --wait
```

Confirm successful deployment by visiting `https://master.nms.awesome.com` and logging in
with the `admin-username` and `admin-password` outputted here.
