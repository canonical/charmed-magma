# Integrate Charmed Magma Access Gateway with Orchestrator

## Relate the Access Gateway with the Orchestrator

Offer the orchestrator relation outside of the orchestrator model:

```{code-block} shell
juju offer orc8r-nginx:orchestrator
```

Configure the Access Gateway to connect to the Orchestrator:

```{code-block} shell
juju relate magma-access-gateway-operator [[<controller>:]<user>/]<model-name>.orc8r-nginx
```

Fetch the Access Gateway's `Hardware ID` and `Challenge Key`:

```{code-block} shell
juju run-action magma-access-gateway-operator/<unit number> get-access-gateway-secrets --wait
```

Navigate to "Equipment" on the NMS via the left navigation bar, hit "Add Gateway" on the upper right, and fill out the multi-step modal form. Use the secrets from above for the "Hardware UUID" and "Challenge Key" fields.

## Verify the deployment

Run the following command:

```{code-block} shell
juju run-action magma-access-gateway-operator/<unit number> post-install-checks --wait
```

```{note}
Successful Access Gateway deployment will be indicated by the `Magma AGW post-installation checks finished successfully.` message.
```
