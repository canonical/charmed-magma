# 1. Getting Started

## Requirements

This tutorial has been written to work on Ubuntu:

- **:material-ubuntu: Operating system**: Ubuntu 20.04
- **:octicons-cpu-16: CPU**: 10 cores
- **:fontawesome-solid-memory: Memory**: 16 GB
- **:material-ethernet: Storage**: 100 GB

## Installing dependencies

First, open a terminal window and install [Juju](https://juju.is/), [Multipass](https://multipass.run/) and [Kubectl](https://kubernetes.io/docs/reference/kubectl/) using snap.

```bash
sudo snap install juju
sudo snap install multipass
sudo snap install kubectl --classic
```

## Creating the environment

Create 3 virtual machines using multipass.

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

Then, install [MicroK8s](https://microk8s.io/) and configure the network:

```bash
ubuntu@magma-orchestrator:~$ sudo snap install microk8s --channel=1.22/stable --classic
ubuntu@magma-orchestrator:~$ sudo ufw default allow routed
```

Add the ubuntu user to the MicroK8s group:

```bash
ubuntu@magma-orchestrator:~$ sudo usermod -a -G microk8s ubuntu
ubuntu@magma-orchestrator:~$ sudo chown -f -R ubuntu ~/.kube
ubuntu@magma-orchestrator:~$ newgrp microk8s
```

Enable the following MicroK8s add-ons:

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
