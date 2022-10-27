# 3. Deploying the 4G core

## Bootstrapping a new Juju controller

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
!!! info
    
    We have now bootstrapped two Juju controllers, one to manage our Kubernetes environment and one to 
    manage our virtual machines environment. From the host, you can always list the controllers by 
    running `juju controllers` and you can switch from one to the other using 
    `juju switch <controller name>`.

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
ubuntu@host:~$ juju machines
Machine  State    Address        Inst id               Series  AZ  Message
0        started  10.24.157.241  manual:10.24.157.241  focal       Manually provisioned machine
```

## Deploying Magma Access Gateway

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

## Registering Access Gateway with Magma Orchestrator

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

## Create a network in Magma Orchestrator

First, create a network # TODO

Then, navigate to "Equipment" on the NMS via the left navigation bar, hit "Add Gateway" on the 
upper right, and fill out the multi-step modal form. Use the secrets from above for the 
"Hardware UUID" and "Challenge Key" fields.

## Verify the Access Gateway deployment

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
