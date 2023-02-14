# Deploy Charmed Magma Access Gateway

## Requirements

The Access Gateway must be installed on an Ubuntu machine with the following specifications:

- **:material-ubuntu: Operating System**: Ubuntu 20.04 LTS with Linux Kernel 5.4
- **:octicons-cpu-16: Processor**: x86-64 dual-core processor (around 2GHz clock speed or faster)
- **:fontawesome-solid-memory: Memory**: 4GB RAM
- **:material-harddisk: Storage**: 32GB or greater SSD
- **:material-ethernet: Networking**: At least two ethernet interfaces (**SGi** for internet connectivity and **S1** for enodeB connectivity)


!!! danger

    Installing this charm will affect the target computer's networking configuration. Make sure it is installed on designated hardware (personal computers are strongly discouraged).

!!! info

    Some clouds like AWS use newer kernel versions by default. If you want to downgrade your kernel, please refer to the following [guide](https://discourse.ubuntu.com/t/how-to-downgrade-the-kernel-on-ubuntu-20-04-to-the-5-4-lts-version/26459).

## Install Magma Access Gateway

=== "Option 1: DHCP network configuration"
    
    Deploy Magma Access Gateway:
    ``` bash
    juju deploy magma-access-gateway-operator --config sgi=enp0s1 --config s1=enp0s2 --channel=1.6/stable
    ```
    
    !!! info
        The interface names will need to be adjusted based on your specific machine.


=== "Option 2: Static network configuration"

    Create a file called `agw_config.yaml` that contains the following content:

    ``` yaml
    ---
    magma-access-gateway-operator:
      sgi: enp0s1
      sgi-ipv4-address: 192.168.0.2/24
      sgi-ipv4-gateway: 192.168.0.1
      sgi-ipv6-address: fd7d:3797:378b:a502::2/64
      sgi-ipv6-gateway: fd7d:3797:378b:a502::1
      s1: enp0s2
      s1-ipv4-address: 192.168.1.2/24
      s1-ipv6-address: fd7d:3797:378b:a503::2/64
      dns: '["8.8.8.8", "208.67.222.222"]'
    ```

    !!! info
        The interface names and IP addresses will need to be adjusted based on your specific machine.

    Deploy Magma Access Gateway:

    ```bash
    juju deploy magma-access-gateway-operator --config agw_config.yaml
    ```

