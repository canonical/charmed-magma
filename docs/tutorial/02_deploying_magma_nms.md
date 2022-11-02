# 2. Deploying Magma's network management software

## Deploying Magma Orchestrator

Make sure you are currently using the `orchestrator` Juju model:

```bash
juju switch orchestrator
```

Create a file called `overlay.yaml` in your current working directory:

```bash
touch overlay.yaml
```

Place the following content into the file:

```yaml title="overlay.yaml"
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

Deploy the `magma-orc8r` bundle with this overlay file:

```bash
juju deploy magma-orc8r --overlay overlay.yaml --trust --channel=beta
```

You can see the deployment's status by running `juju status`. The deployment is completed when 
all units are in the `Active-Idle` state.


!!! info

    This step can take a lot of time, expect between 10-30 minutes.

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

Retrieve the PFX package that contains the certificates to authenticate against Magma Orchestrator.
The pfx package will be copied to your current working directory. 

```bash
juju scp --container="magma-orc8r-certifier" orc8r-certifier/0:/var/opt/magma/certs/admin_operator.pfx admin_operator.pfx
```

Retrieve the PFX package's password:

```bash
juju run-action orc8r-certifier/leader get-pfx-package-password --wait
```

The output should look like so:

```bash
ubuntu@host:~$ juju run-action orc8r-certifier/leader get-pfx-package-password --wait
unit-orc8r-certifier-0:
  UnitId: orc8r-certifier/0
  id: "8"
  results:
    password: wufoaMzEU7bg
  status: completed
  timing:
    completed: 2022-10-27 14:15:07 +0000 UTC
    enqueued: 2022-10-27 14:15:05 +0000 UTC
    started: 2022-10-27 14:15:06 +0000 UTC
```

If you are using Google Chrome, navigate to `chrome://settings/certificates?search=https`, click on 
Import, select the `admin_operator.pfx` package that we just copied and write in the password that you received.

## Setupping DNS

Retrieve the list of services that need to be exposed:

```bash
juju run-action orc8r-orchestrator/leader get-load-balancer-services --wait
```

The result should look like so:

```bash
ubuntu@host:~$ juju run-action orc8r-orchestrator/leader get-load-balancer-services --wait
unit-orc8r-orchestrator-0:
  UnitId: orc8r-orchestrator/0
  id: "4"
  results:
    nginx-proxy: 10.0.1.1
    orc8r-bootstrap-nginx: 10.0.1.3
    orc8r-clientcert-nginx: 10.0.1.4
    orc8r-nginx-proxy: 10.0.1.2
  status: completed
  timing:
    completed: 2022-10-27 13:53:38 +0000 UTC
    enqueued: 2022-10-27 13:53:37 +0000 UTC
    started: 2022-10-27 13:53:37 +0000 UTC
```

At this point, we have Orchestrator up and running and available on private IP addresses. We will
now create entries in your `/etc/hosts` file so that you can reach Magma Orchestrator via domain
names. Here replace the IP addresses with the one that you received:

```bash
echo "10.0.1.2  api.awesome.com" >> /etc/hosts
echo "10.0.1.3  bootstrapper-controller.awesome.com" >> /etc/hosts
echo "10.0.1.4  controller.awesome.com" >> /etc/hosts
echo "10.0.1.1  master.nms.awesome.com" >> /etc/hosts
echo "10.0.1.1  magma-test.nms.awesome.com" >> /etc/hosts
```

!!! tip

    Make sure to follow the corresponding IP/hostname scheme:

    | Address                                | Hostname                              | 
    |----------------------------------------|---------------------------------------|
    | `<orc8r-bootstrap-nginx External IP>`  | `bootstrapper-controller.awesome.com` | 
    | `<orc8r-nginx-proxy External IP>`      | `api.awesome.com`                     | 
    | `<orc8r-clientcert-nginx External IP>` | `controller.awesome.com`              | 
    | `<nginx-proxy External IP>`            | `*.nms.awesome.com`                   | 

Now, navigate to `https://master.nms.awesome.com`, you should receive a warning because we are
using self-signed-certificates, click on "Proceed".

## Verifying the deployment

Get the master organization's username and password:

```bash
juju run-action nms-magmalte/leader get-master-admin-credentials --wait
```

Your result should look like so:

```bash
ubuntu@host:~$ juju run-action nms-magmalte/leader get-master-admin-credentials --wait
unit-nms-magmalte-0:
  UnitId: nms-magmalte/0
  id: "6"
  results:
    admin-password: oTKcM6G9ylG9
    admin-username: admin@juju.com
  status: completed
  timing:
    completed: 2022-10-27 14:13:43 +0000 UTC
    enqueued: 2022-10-27 14:13:41 +0000 UTC
    started: 2022-10-27 14:13:43 +0000 UTC
```

!!! note

    Your password will be different from the one here

Confirm successful deployment by visiting `https://master.nms.awesome.com` and logging in
with the `admin-username` and `admin-password` outputted here.
