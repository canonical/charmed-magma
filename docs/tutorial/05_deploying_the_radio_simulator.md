# 5. Deploying the radio simulator

## Create an instance on AWS

Create an AWS EC2 instance running Ubuntu 20.04:

```{code-block} shell
aws ec2 run-instances \
  --security-group-ids <your security group> \
  --placement AvailabilityZone=us-east-2a \
  --image-id ami-0568936c8d2b91c4e \
  --count 1 \
  --instance-type t2.xlarge \
  --key-name <your ssh key name> \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=srsran}]' \
  --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 50 } } ]"
```

Replace the security group ID with one that allows SSH access and note the instance ID.

## Attach a secondary network interface to the instance

Using the same **S1** subnet that was created during step 3, create a new network interface:

```{code-block} shell
aws ec2 create-network-interface --subnet-id <your subnet ID> --group <your security group> --tag-specifications 'ResourceType=network-interface,Tags=[{Key=Name,Value=radio-simulator-s1}]'
```

Attach the network interface to the EC2 instance:

```{code-block} shell
aws ec2 attach-network-interface --network-interface-id <your network interface ID> --instance-id <your instance ID> --device-index 1
```

## Add the machine to Juju

Wait for the instance to boot up and be accessible via SSH, then add it as a Juju machine:

```{code-block} shell
juju add-machine --private-key=<path to your private key> ssh:ubuntu@<EC2 instance public IP address>
```

## Configure Netplan to use the secondary network interface

SSH into the machine:

```{code-block} shell
juju ssh <Your instance ID>
```

Retrieve the mac address used by `eth1`:

```{code-block} shell
ip a show eth1
```

Create a file named `99-srsran.yaml` that contains the following content and move it over to `/etc/netplan/`:

```{code-block} yaml
:caption: 99-srsran.yaml
network:
  version: 2
  ethernets:
    eth1:
      dhcp4: true
      dhcp6: false
      match:
        macaddress: <eth1 interface mac address>
      set-name: eth1
```

Apply the netplan configuration:

```{code-block} shell
sudo netplan apply
```

## Deploy the srsRAN radio simulator

Deploy srsRAN to the machine:

```{code-block} shell
juju deploy srs-enb-ue --channel=edge --config bind-interface="eth1" --to <Machine ID>
```

## Integrate the radio simulator with Magma Access Gateway

```{code-block} shell
juju relate srs-enb-ue:lte-core magma-access-gateway-operator:lte-core
```
