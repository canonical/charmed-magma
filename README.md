# Tutorial: Running your 4G Network on Ubuntu

## Overview

[Magma](https://magmacore.org/) is an open-source software platform that gives network operators 
an open, flexible and extendable mobile core network solution.

[Juju](https://juju.is/) is a tool used to deploy cloud infrastructure and applications and manage their operations 
from Day 0 through Day 2.

In this tutorial, we will use Juju to deploy the Magma 4G core as well as a simulated radio
and a cellphone from the [srsRAN](https://www.srslte.com/) project to showcase that our network 
is actually working.

## Getting Started

This tutorial has been written to work on a Ubuntu 20.04 computer with at least 16 GB of RAM, 10 
CPU cores and 100 GB of storage.

### Installing dependencies

First, open a terminal window and install Juju, Multipass and kubectl.

```bash
ubuntu@host:~$ sudo snap install juju
ubuntu@host:~$ sudo snap install multipass
ubuntu@host:~$ sudo snap install kubectl --classic
```

### Creating the environment

First, create 3 virtual machines using multipass.

```bash
ubuntu@host:~$ multipass launch --name magma-orchestrator --mem=8G --disk=40G --cpus=6 20.04
ubuntu@host:~$ multipass launch --name magma-access-gateway --mem=4G --disk=40G --cpus=2 --network=mpbr0 20.04
ubuntu@host:~$ multipass launch --name srsran --mem=4G --disk=20G --cpus=2 20.04
```

List the created virtual machines and their addresses:

```bash
ubuntu@host:~$ multipass list
Name                    State             IPv4             Image
magma-access-gateway    Running           10.24.157.231    Ubuntu 22.04 LTS
magma-orchestrator      Running           10.24.157.52     Ubuntu 22.04 LTS
srsran                  Running           10.24.157.67     Ubuntu 22.04 LTS
```

Note the addresses associated with each virtual machine, we will need those later. Yours will be 
different of course.

Now, connect to the virtual machine that we named `magma-orchestrator`:

```bash
ubuntu@host:~$ multipass shell magma-orchestrator
```

Then install MicroK8s and configure the network:

```bash
ubuntu@magma-orchestrator:~$ sudo snap install microk8s --channel=1.22/stable --classic
ubuntu@magma-orchestrator:~$ sudo ufw default allow routed
```

Add the ubuntu user to the microk8s group:

```bash
ubuntu@magma-orchestrator:~$ sudo usermod -a -G microk8s ubuntu
ubuntu@magma-orchestrator:~$ sudo chown -f -R ubuntu ~/.kube
ubuntu@magma-orchestrator:~$ newgrp microk8s
```

Enable the following microk8s add-ons:

```bash
ubuntu@magma-orchestrator:~$ microk8s enable dns storage
```

Enable the metallb add-on. Here we need to provide a range of 5 IP addresses on the same subnet
that is already used by the VM. Make sure to use a range that does not include any of the 3 addresses
provided to the VM's.

```bash
ubuntu@magma-orchestrator:~$ microk8s enable metallb:10.24.157.80-10.24.157.85
```

Output the kubernetes configuration to a file:

```bash
ubuntu@magma-orchestrator:~$ microk8s config > config
```

Now, from the host terminal, retrieve the configuration file and place it under the `~/.kube/` 
directory:

```bash
ubuntu@host:~$ multipass transfer magma-orchestrator:config .
ubuntu@host:~$ mv config ~/.kube/
```

Validate that you can run kubectl commands:

```bash
ubuntu@host:~$ kubectl get nodes
NAME                 STATUS   ROLES    AGE    VERSION
magma-orchestrator   Ready    <none>   104s   v1.25.2
```

## Deploying Magma's network management software

### Bootstrapping a Juju controller

Bootstrap a Juju controller on the Kubernetes instance we just created:

```bash
ubuntu@host:~$ juju add-k8s magma-orchestrator-k8s --client
ubuntu@host:~$ juju bootstrap magma-orchestrator-k8s
ubuntu@host:~$ juju add-model magma-orchestrator
```

### Deploying Magma Orchestrator

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
all units are in the `Active-Idle` state. This step can take a lot of time, expect at least 
10-15 minutes.

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

### Getting Access to Magma Orchestrator

First, retrieve the PFX package and password that contains the certificates to authenticate against 
Magma Orchestrator:

```bash
ubuntu@host:~$ juju scp --container="magma-orc8r-certifier" orc8r-certifier/0:/var/opt/magma/certs/admin_operator.pfx admin_operator.pfx
ubuntu@host:~$ juju run-action orc8r-certifier/leader get-pfx-package-password --wait
```

The pfx package was copied to your current working directory. If you are using Google Chrome, 
navigate to `chrome://settings/certificates?search=https`, click on Import, select 
the `admin_operator.pfx` package that we just copied and write in the password that you received.

> **SHOW PICTURE OF HOW THIS IS LOADED IN GOOGLE CHROME**  # TODO

### Setupping DNS

Now, retrieve the list of services that need to be exposed:

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

### Offer an application endpoint

Offer an application endpoint that we will use later for our network core to 
relate to our orchestrator:

```bash
ubuntu@host:~$ juju offer orc8r-nginx:orchestrator
```

### Verify the deployment

Get the master organization's username and password:

```bash
ubuntu@host:~$ juju run-action nms-magmalte/leader get-master-admin-credentials --wait
```

Confirm successful deployment by visiting `https://master.nms.awesome.com` and logging in
with the `admin-username` and `admin-password` outputted here.


## Deploying the 4G core

### Bootstrapping a new Juju controller

First, create a shell in the `magma-access-gateway` virtual machine and list all the network 
interfaces it has:

```bash
ubuntu@host:~$ multipass shell magma-access-gateway
ubuntu@magma-access-gateway:~$ ip -br address show scope global
enp5s0           UP             10.24.157.111/24 metric 100 fd42:c027:d54:8986:5054:ff:fe10:62b8/64 
enp6s0           UP             10.24.157.70/24 metric 200 fd42:c027:d54:8986:5054:ff:fe0a:6671/64
```

Note the two interfaces, **enp5s0** and **enp6s0** in my example. Yours may vary.

From the host, bootstrap a **new** juju controller:

```bash
ubuntu@host:~$ juju bootstrap localhost virtual-machine
```

> We are now using two juju controllers, one to manage our Kubernetes environment and the second to 
> manage our virtual machines environment. From the host, you can always list the controllers by 
> running `juju controllers` and you can switch from one to the other using 
> `juju switch <controller name>`.

Copy the `magma-access-gateway` private ssh key to your host's home directory and change its permission
for it to be usable by juju:

```bash
ubuntu@host:~$ sudo cp /var/snap/multipass/common/data/multipassd/ssh-keys/id_rsa .
ubuntu@host:~$ sudo chmod 600 id_rsa
ubuntu@host:~$ sudo chown $USER id_rsa
```

From the `virtual-machine` juju controller, add the access-gateway virtual machine to Juju. Here use
the actual IP address of the `magma-access-gateway` machine:

```bash
ubuntu@host:~$ juju add-machine ssh:ubuntu@10.24.157.111 --private-key=id_rsa
```

Validate that the machine is available:

```bash
guillaume@thinkpad:~/orc8r_deployment$ juju machines
Machine  State    Address        Inst id               Series  AZ  Message
0        started  10.24.157.241  manual:10.24.157.241  focal       Manually provisioned machine
```

### Deploying Magma Access Gateway

Deploy Access Gateway with the interfaces listed earlier (enp5s0 and enp6s0):

```bash
ubuntu@host:~$ juju deploy magma-access-gateway-operator --config sgi=enp5s0 --config s1=enp6s0 --channel=beta --to 0
```

You can see the deployment's status by running `juju status`. The deployment is completed when 
the application is in the `Active-Idle` state. This step can take a lot of time, expect at least 
10-15 minutes.

```bash
ubuntu@host:~$ juju status
Model    Controller        Cloud/Region         Version  SLA          Timestamp
default  virtual-machines  localhost/localhost  2.9.35   unsupported  15:46:28-04:00

App                            Version  Status  Scale  Charm                          Channel  Rev  Exposed  Message
magma-access-gateway-operator           active      1  magma-access-gateway-operator  beta      14  no       

Unit                              Workload  Agent  Machine  Public address  Ports  Message
magma-access-gateway-operator/0*  active    idle   0        10.24.157.241          

Machine  State    Address        Inst id               Series  AZ  Message
0        started  10.24.157.241  manual:10.24.157.241  focal       Manually provisioned machine
```

### Registering Access Gateway with Magma Orchestrator

Relate the newly created Magma Access Gateway with the Orchestrator, leveraging the offer
we created earlier.

```bash
ubuntu@host:~$ juju relate magma-access-gateway-operator magma-orchestrator-k8s:magma-orchestrator.orc8r-nginx
```

Wait for the application to go back to `Active-Idle`:

```bash

ubuntu@host:~$ juju status
Model    Controller        Cloud/Region         Version  SLA          Timestamp
default  virtual-machines  localhost/localhost  2.9.35   unsupported  15:50:07-04:00

SAAS         Status  Store                  URL
orc8r-nginx  active  google-gke-2-us-east1  admin/burger.orc8r-nginx

App                            Version  Status  Scale  Charm                          Channel  Rev  Exposed  Message
magma-access-gateway-operator           active      1  magma-access-gateway-operator  beta      14  no       

Unit                              Workload  Agent  Machine  Public address  Ports  Message
magma-access-gateway-operator/0*  active    idle   0        10.24.157.241          

Machine  State    Address        Inst id               Series  AZ  Message
0        started  10.24.157.241  manual:10.24.157.241  focal       Manually provisioned machine
```

Fetch the Access Gateway's `Hardware ID` and `Challenge Key`:

```bash
ubuntu@host:~$ juju run-action magma-access-gateway-operator/0 get-access-gateway-secrets --wait
unit-magma-access-gateway-operator-0:
  UnitId: magma-access-gateway-operator/0
  id: "8"
  results:
    challenge-key: MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEto/TpTbUBHpJmIGKzyLSEXtkZ0B9gXpJoBR49jUbj4vy2pO8vdL+0r38kj1NhnGOSF7mnUYwFRFYohodC0jufCYrBhNFmx5KS0qdAHDWzohC4ss7+8zdtkZAToPJvS25
    hardware-id: c9cb1e0e-30cc-4f4f-a832-00980c1dd654
  status: completed
  timing:
    completed: 2022-10-20 18:39:52 +0000 UTC
    enqueued: 2022-10-20 18:39:48 +0000 UTC
    started: 2022-10-20 18:39:51 +0000 UTC
```

Your `challenge-key` and `hardware-id` will be different from those here. We will use those soon.

### Create a network in Magma Orchestrator

First, create a network # TODO

Then, navigate to "Equipment" on the NMS via the left navigation bar, hit "Add Gateway" on the 
upper right, and fill out the multi-step modal form. Use the secrets from above for the 
"Hardware UUID" and "Challenge Key" fields.

### Verify the Access Gateway deployment

Verify that the Access Gateway is properly running:

```bash
ubuntu@host:~$ juju run-action magma-access-gateway-operator/0 post-install-checks --wait
unit-magma-access-gateway-operator-0:
  UnitId: magma-access-gateway-operator/0
  id: "8"
  results:
    post-install-checks-output: Magma AGW post-installation checks finished successfully.
  status: completed
  timing:
    completed: 2022-10-20 19:57:38 +0000 UTC
    enqueued: 2022-10-20 19:57:36 +0000 UTC
    started: 2022-10-20 19:57:38 +0000 UTC
```

Make sure the output is `Magma AGW post-installation checks finished successfully.`

## Deploying a radio simulator # TODO


## Destroying the environment

First, destroy the 3 virtual machines that we created:

```bash
ubuntu@host:~$ multipass delete --all
```

Then, uninstall all the installed packages:

```bash
ubuntu@host:~$ sudo snap remove juju --purge
ubuntu@host:~$ sudo snap remove multipass --purge
ubuntu@host:~$ sudo snap remove kubectl --purge
```
