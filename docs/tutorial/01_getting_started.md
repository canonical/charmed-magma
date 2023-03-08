# 1. Getting Started


## Install dependencies

From your Ubuntu machine, open a terminal window and install [Juju](https://juju.is/), and [Kubectl](https://kubernetes.io/docs/reference/kubectl/) using snap.

```bash
snap install juju --classic
snap install kubectl --classic
```

You will also need to install the AWS `eksctl` command line tool. You can find the instructions to install it [here](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).

## Bootstrap a Juju controller on AWS

Add your AWS credentials to Juju:

```console
juju add-credential aws
```

Bootstrap a juju controller on the host:

```console
juju bootstrap aws/us-east-2
```

[//]: # ()
[//]: # (### Create juju models)

[//]: # ()
[//]: # (Create the following Juju models:)

[//]: # ()
[//]: # (```console)

[//]: # (juju add-model edge aws/us-east-2)

[//]: # (juju add-model orc8r eks-magma-orc8r/us-east-2)

[//]: # (```)

[//]: # ()
[//]: # (Make sure the two models are properly created:)

[//]: # ()
[//]: # (```console)

[//]: # (juju models)

[//]: # (```)

[//]: # ()
[//]: # (The result should look like:)

[//]: # ()
[//]: # (```console)

[//]: # (ubuntu@host:~$ juju models)

[//]: # (Controller: aws-us-east-2)

[//]: # ()
[//]: # (Model       Cloud/Region               Type        Status     Machines  Cores  Access  Last connection)

[//]: # (controller  aws/us-east-2              ec2         available         1      2  admin   just now)

[//]: # (default     aws/us-east-2              ec2         available         0      -  admin   5 minutes ago)

[//]: # (edge        aws/us-east-2              ec2         available         0      -  admin   never connected)

[//]: # (orc8r*      eks-magma-orc8r/us-east-2  kubernetes  available         0      -  admin   never connected)

[//]: # (```)

[//]: # ()
[//]: # (!!! info)

[//]: # (    )
[//]: # (    At this point we have a Juju controllers with two models. One for the virtual machines)

[//]: # (    and one for Kubernetes. You can switch between the two models using `juju switch <model name>`.)

[//]: # ()
[//]: # (### Adding virtual machines to the Juju controller)

[//]: # ()
[//]: # (Create two juju machines in the `edge` model:)

[//]: # ()
[//]: # (```console)

[//]: # (juju add-machine --constraints="spaces=sgi,s1 mem=8G cores=2 root-disk=30G zones=us-east-2a")

[//]: # (juju add-machine --constraints="spaces=s1 mem=8G cores=2 root-disk=30G zones=us-east-2a")

[//]: # (```)

[//]: # ()
[//]: # (The first one will be for Magma Access Gateway and the second one for the Radio simulator.)

[//]: # ()
[//]: # (Validate that the machines are available:)

[//]: # ()
[//]: # (```console)

[//]: # (juju machines)

[//]: # (```)

[//]: # ()
[//]: # (The output should look like:)

[//]: # ()
[//]: # (```console)

[//]: # (ubuntu@host:~$ juju machines)

[//]: # (Machine  State    Address       Inst id              Series  AZ  Message)

[//]: # (0        started  10.24.157.76  manual:10.24.157.76  focal       Manually provisioned machine)

[//]: # (```)

[//]: # ()
[//]: # (!!! info)

[//]: # (    )
[//]: # (    At this point we have:)

[//]: # (    - A Juju controller)

[//]: # (    - A `edge` Juju models that contains)

[//]: # (      - Two machines)

[//]: # (    - A `orc8r` Juju model)