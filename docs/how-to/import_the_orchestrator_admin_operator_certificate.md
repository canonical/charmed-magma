# Import the Orchestrator admin operator certificate

The Orchestrator admin operator certificate is needed to make API calls to Orchestrator and to use its swagger documentation. Use this how-to guide to retrieve the certificate and load it in your browser.

First, retrieve the PFX package that contains the certificates to authenticate against Magma Orchestrator:

```{code-block} shell
juju scp --container="magma-orc8r-certifier" orc8r-certifier/0:/var/opt/magma/certs/admin_operator.pfx admin_operator.pfx
```

Then, retrieve the PFX package password:

```{code-block} shell
juju run orc8r-certifier/leader get-pfx-package-password
```

```{info}
The pfx package was copied to your current working directory. It can now be loaded in your browser or used to make API calls to Magma orchestrator.
```
