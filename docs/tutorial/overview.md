# Operate your own private mobile network with Magma

In this tutorial, we will use Juju to deploy Magma's 4G core network as well as a simulated radio and a cellphone from the [srsRAN](https://www.srslte.com/) project.

1. [Getting Started](01_getting_started.md)
2. [Deploying Magma Orchestrator](02_deploying_magma_orchestrator.md)
3. [Deploying the 4G core](03_deploying_magma_access_gateway.md)
4. [Integrating Magma Access Gateway with Magma Orchestrator](04_integrating_magma_access_gateway_with_magma_orchestrator.md)
5. [Deploying the radio simulator](05_deploying_the_radio_simulator.md)
6. [Simulating user traffic](06_simulating_user_traffic.md)
7. [Destroying the environment](07_destroying_the_environment.md)

## Requirements

* **:material-aws:** An AWS account[^1]
* **:material-dns:** A public domain
* **:material-ubuntu:** A computer[^2] with the following software installed:
    * [juju 2.9](https://juju.is/docs/olm/install-juju)
    * [kubectl](https://kubernetes.io/docs/tasks/tools/)
    * [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    * [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

[^1]: This tutorial uses AWS as the cloud provider. You can use any cloud provider that Juju supports. See [Juju Clouds](https://juju.is/docs/olm/juju-supported-clouds) for more information.
[^2]: All the commands were tested from a Ubuntu 22.04 LTS machine.
