# 3. Deploying the 4G core

## Deploying Magma Access Gateway

First, list all the network interfaces that magma-access-gateway has:

```bash
multipass exec magma-access-gateway -- ip -br address show scope global
```

The result should look like so:

```bash
ubuntu@host:~$ multipass exec magma-access-gateway -- ip -br address show scope global
enp5s0           UP             10.24.157.76/24 fd42:c027:d54:8986:5054:ff:feb4:d6b2/64 
enp6s0           UP             10.209.93.17/24 fd42:74e4:d36e:d16d:5054:ff:feae:17d6/64
```

Note the two interfaces, **enp5s0** and **enp6s0** in my example. Yours may vary.

Deploy Access Gateway with the 2 network interfaces listed (**enp5s0** and **enp6s0** in this example):

```bash
juju deploy magma-access-gateway-operator --config sgi=enp5s0 --config s1=enp6s0 --channel=beta --to 0
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
