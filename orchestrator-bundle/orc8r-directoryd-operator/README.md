# magma-orc8r-directoryd

## Description
magma-orc8r-directoryd stores subscriber identity (e.g. IMSI, IP address, MAC address) and location (gateway hardware ID).

## Usage

```bash
juju deploy postgresql-k8s
juju deploy ./magma-orc8r-directoryd_ubuntu-20.04-amd64.charm \
  --resource magma-orc8r-directoryd-image=docker.artifactory.magmacore.org/controller:1.6.0 \
  orc8r-directoryd
juju relate orc8r-directoryd postgresql-k8s:db
```

## Relations

The magma-orc8r-directoryd service relies on a relation to a Database. 

The current setup has only been tested with relation to the `postgresql-k8s` charm.

## OCI Images

Default: docker.artifactory.magmacore.org/controller:1.6.0

## Contributing

Please see `CONTRIBUTING.md` for developer guidance.