# 6. Destroying the environment

First, destroy the 3 virtual machines that we created:

```bash
ubuntu@host:~$ multipass delete --all
```

Then, uninstall all the installed packages:

```bash
ubuntu@host:~$ sudo snap remove juju --purge
ubuntu@host:~$ sudo snap remove multipass --purge
ubuntu@host:~$ sudo snap remove kubectl --purge
```
