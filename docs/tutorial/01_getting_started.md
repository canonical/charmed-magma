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
