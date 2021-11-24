# magma-nms-nginx-proxy

## Description

Magma’s NMS provides a single pane of glass for managing Magma based networks. NMS provides the
ability to configure gateways and associated eNodeBs, provides visibility into status, events and
metrics observed in these networks and finally ability to configure and receive alerts.
<br>
Visit [Magma NMS Overview](https://docs.magmacore.org/docs/nms/nms_arch_overview) to learn more.

This [Juju](https://juju.is/) Charm deploys an **nginx** web server that proxies communication
between NMS UI and MagmaLTE.<br>
This charm is part of the [Charmed Magma bundle](https://github.com/canonical/charmed-magma).

## Usage

**magma-nms-nginx-proxy** can be deployed via Juju command line using below commands:

```bash
juju deploy ./magma-nms-nginx-proxy_ubuntu-20.04-amd64.charm \
  --resource magma-nms-nginx-proxy-image=nginx:latest \
  nms-nginx-proxy
```

To work correctly, **magma-nms-nginx-proxy** requires **magma-orc8r-certifier** and 
**magma-nms-magmalte** (for details, check the _Relations_ section below).

To deploy **magma-orc8r-certifier** from Juju command line:

```bash
juju deploy ../orc8r-certifier-operator/magma-orc8r-certifier_ubuntu-20.04-amd64.charm \
  --resource magma-orc8r-certifier-image=docker.artifactory.magmacore.org/controller:1.6.0 \
  --config domain=example.com \
  orc8r-certifier
juju relate nms-nginx-proxy orc8r-certifier
```

To deploy **magma-nms-magmalte** from Juju command line:

```bash
juju deploy ../nms-magmalte-operator/magma-nms-magmalte_ubuntu-20.04-amd64.charm \
  --resource magma-nms-magmalte-image=docker.artifactory.magmacore.org/magmalte:1.6.0 \
  nms-magmalte
juju relate nms-nginx-proxy nms-magmalte
```

Before running any **juju deploy** commands, make sure charm has been built using:
```bash
charmcraft pack
```

## Relations

Currently supported relations are:

- [magma-nms-magmalte](https://github.com/canonical/charmed-magma/tree/main/orchestrator-bundle/nms-magmalte-operator) - Magmalte is
  a microservice built using express framework. It contains set of application and router level
  middlewares. It uses sequelize ORM to connect to the NMS DB for servicing any routes involving DB
  interaction.
- [magma-orc8r-certifier](https://github.com/canonical/charmed-magma/tree/main/orchestrator-bundle/orc8r-certifier-operator) -
  magma-orc8r-certifier maintains and verifies signed client certificates and their associated
  identities.

## TODO

- [ ] Add relation to [NMS UI](https://docs.magmacore.org/docs/nms/nms_arch_overview#nms-ui) once
  it's charmed.

## OCI Images

Default: nginx:latest

## Contributing

Please see `CONTRIBUTING.md` for developer guidance.