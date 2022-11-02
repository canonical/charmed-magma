# 1. Getting Started

## Requirements

This tutorial has been written to work on Ubuntu:

- **:material-ubuntu: Operating system**: Ubuntu 20.04
- **:octicons-cpu-16: CPU**: 10 cores
- **:fontawesome-solid-memory: Memory**: 16 GB
- **:material-ethernet: Storage**: 100 GB

## Installing dependencies

First, open a terminal window and install [Juju](https://juju.is/), [Multipass](https://multipass.run/), [MicroK8s](https://microk8s.io/) and [Kubectl](https://kubernetes.io/docs/reference/kubectl/) using snap.

```bash
snap install juju --classic
snap install multipass
snap install kubectl --classic
snap install microk8s --channel=1.22/stable --classic
```

## Creating the environment

On our Ubuntu machine, we will create networks, deploy Kubernetes and bootstrap a Juju controller.

### Creating networks using lxc

Create two bridge networks using `lxc`, called `sgi` and `s1`:

```bash
lxc network create sgi --type=bridge
```

```bash
lxc network create s1 --type=bridge
```

List the known networks to lxc:

```bash
lxc network list
```

Your results here may vary depending on your specific setup, but you should end up with two lines
with the `s1` and `sgi` network names:

```bash
ubuntu@host:~$ lxc network list
+--------+----------+---------+-----------------+---------------------------+------------------------------+---------+---------+
|  NAME  |   TYPE   | MANAGED |      IPV4       |           IPV6            |         DESCRIPTION          | USED BY |  STATE  |
+--------+----------+---------+-----------------+---------------------------+------------------------------+---------+---------+
| lxdbr0 | bridge   | YES     | 10.209.93.1/24  | fd42:74e4:d36e:d16d::1/64 |                              | 118     | CREATED |
+--------+----------+---------+-----------------+---------------------------+------------------------------+---------+---------+
| mpbr0  | bridge   | YES     | 10.24.157.1/24  | fd42:c027:d54:8986::1/64  | Network bridge for Multipass | 0       | CREATED |
+--------+----------+---------+-----------------+---------------------------+------------------------------+---------+---------+
| s1     | bridge   | YES     | 10.162.205.1/24 | fd42:3fd1:b85d:4565::1/64 |                              | 0       | CREATED |
+--------+----------+---------+-----------------+---------------------------+------------------------------+---------+---------+
| sgi    | bridge   | YES     | 10.195.157.1/24 | fd42:c28:edf1:184a::1/64  |                              | 0       | CREATED |
+--------+----------+---------+-----------------+---------------------------+------------------------------+---------+---------+
| wlp9s0 | physical | NO      |                 |                           |                              | 0       |         |
+--------+----------+---------+-----------------+---------------------------+------------------------------+---------+---------+
```

### Creating a Virtual machine

Create a virtual machines for Magma's access gateway:

```bash
multipass launch --name magma-access-gateway --mem=4G --disk=40G --cpus=2 --network=sgi --network s1 20.04
```

You can see your created machine by running:

```bash
multipass list
```

The output should look like:

```bash
ubuntu@host:~$ multipass list
Name                    State             IPv4             Image
magma-access-gateway    Running           10.24.157.232    Ubuntu 20.04 LTS
```

!!! bug
    
    There is a bug in Magma preventing the use of recent kernel versions, hence the necessity
    to run inside of a virtual machine environment with a known kernel version. This section
    should be removed once the issue is fixed.


### Creating a Kubernetes cluster

Add the ubuntu user to the microk8s group:

```bash
sudo usermod -a -G microk8s $USER
```

Modify the ownership of the `~/.kube` directory:
```bash
sudo chown -f -R $USER ~/.kube
```

Log in to the `microk8s` group:

```bash
newgrp microk8s
```

Enable the following MicroK8s add-ons:

```bash
microk8s enable dns storage
```

Enable the metallb add-on with a range of any 5 IP addresses:

```bash
microk8s enable metallb:10.0.1.1-10.0.1.10
```

Output the kubernetes configuration to a file:

```bash
microk8s config > ~/.kube/config
```

Validate that you can run kubectl commands:

```bash
kubectl get nodes
```

The result should look like:

```bash
ubuntu@host:~$ kubectl get nodes
NAME                 STATUS   ROLES    AGE    VERSION
magma-orchestrator   Ready    <none>   104s   v1.25.2
```

### Bootstrapping the Juju controller

Bootstrap a juju controller on the host:

```bash
juju bootstrap localhost localhost
```

Create a model called `lxd` that will hold srsRAN and Access Gateway:

```bash
juju add-model lxd
```

Add a new cloud to the list of Juju's known clouds:

```bash
juju add-k8s localhost-microk8s --client --controller localhost
```

Create a model called `orchestrator` in the Kubernetes cluster:

```bash
juju add-model orchestrator localhost-microk8s
```

Make sure the two models are properly created:

```bash
juju models
```

The result should look like:

```bash
ubuntu@host:~$ juju models
Controller: localhost

Model          Cloud/Region                  Type        Status     Machines  Access  Last connection
controller     localhost/localhost           lxd         available         1  admin   just now
default        localhost/localhost           lxd         available         0  admin   1 minute ago
orchestrator*  localhost-microk8s/localhost  kubernetes  available         0  admin   never connected
vms            localhost/localhost           lxd         available         0  admin   48 seconds ago

```

!!! info
    
    At this point we have a Juju controllers with two models. One for the virtual machines
    and one for Kubernetes. You can switch between the two models using `juju switch <model name>`.

### Adding virtual machines to the Juju controller

Copy the `magma-access-gateway` private ssh key to your host's home directory and change its permission
for it to be usable by juju:

```bash
sudo cp /var/snap/multipass/common/data/multipassd/ssh-keys/id_rsa .
sudo chmod 600 id_rsa
sudo chown $USER id_rsa
```

From the `virtual-machine` juju controller, add the access-gateway virtual machine to Juju:

```bash
juju add-machine ssh:ubuntu@10.24.157.232 --private-key=id_rsa
```

!!! warning

    Make sur you use the actual IP address of the magma-access-gateway machine!

Validate that the machine is available:

```bash
juju machines
```

The output should look like:

```bash
ubuntu@host:~$ juju machines
Machine  State    Address       Inst id              Series  AZ  Message
0        started  10.24.157.76  manual:10.24.157.76  focal       Manually provisioned machine
```
