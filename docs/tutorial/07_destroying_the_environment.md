# 7. Destroying the environment

First, destroy the 3 virtual machines that we created:

```bash
multipass delete --all
```

Then, uninstall all the installed packages:

```bash
sudo snap remove juju --purge
sudo snap remove multipass --purge
sudo snap remove kubectl --purge
sudo snap remove microk8s --purge
```
