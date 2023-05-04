# Tutorial

In this tutorial, we will use Juju to deploy and run Magma's 4G core network on AWS. We will also
deploy a radio and cellphone simulator from the [srsRAN](https://www.srslte.com/) project to
simulate usage of this network.

Charmed Magma is a complex piece of software.

This tutorial will introduce you to key concepts, tools, processes and
operations, guiding you through your first cloud deployment.
You can expect to spend one to two hours working through the complete
tutorial. It is a strongly recommended investment of time if you are new to
Charmed Magma - it will save you many more hours later on. Follow the
tutorial steps in sequence; they take you on a learning journey through Charmed Magma.

The tutorial has been tested with a variety of users. We make every effort to
keep it up-to-date and ensure that it’s reliable - but if you encounter any
problems, we want to help you, so please let us know.

Follow the core tutorial steps in sequence; they take you on a learning
journey through the Charmed Magma.

```{toctree}
:maxdepth: 1

01_getting_started
02_deploying_magma_orchestrator
03_deploying_magma_access_gateway
04_integrating_magma_access_gateway_with_magma_orchestrator
05_deploying_the_radio_simulator
06_simulating_user_traffic
07_destroying_the_environment
reference
```

## Pre-requisites

* An AWS account[^1]
* A public domain
* A computer[^2] with the following software installed:
   * [juju 2.9](https://juju.is/docs/olm/install-juju)
   * [kubectl](https://kubernetes.io/docs/tasks/tools/)
   * [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   * [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

[^1]: This tutorial uses AWS as the cloud provider. You can use any cloud provider that Juju supports. See [Juju Clouds](https://juju.is/docs/olm/juju-supported-clouds) for more information.
[^2]: All the commands were tested from a Ubuntu 22.04 LTS machine.
