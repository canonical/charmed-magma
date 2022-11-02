# 4. Relating the Orchestrator to the 4G core


## Offering an application endpoint

Offer an application endpoint that we will use later for our network core to 
relate to our orchestrator:

```bash
juju offer orc8r-nginx:orchestrator
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

## Creating a network in Magma Orchestrator

First, create a network # TODO

Then, navigate to "Equipment" on the NMS via the left navigation bar, hit "Add Gateway" on the 
upper right, and fill out the multi-step modal form. Use the secrets from above for the 
"Hardware UUID" and "Challenge Key" fields.

## Verifying the Access Gateway deployment

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
