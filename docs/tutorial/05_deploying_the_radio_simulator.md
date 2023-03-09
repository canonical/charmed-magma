# 5. Deploying the radio simulator

## Create an instance on AWS

Create an AWS EC2 instance running Ubuntu 20.04:

```console
aws ec2 run-instances \
  --security-group-ids <your security group> \
  --image-id ami-0568936c8d2b91c4e \
  --count 1 \
  --instance-type t2.xlarge \
  --key-name <your ssh key name> \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=srsran}]' \
  --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 50 } } ]"
```

Replace the security group ID with one that allows SSH access and note the instance ID.

## Attach a secondary network interface to the instance

Using the same `S1` subnet that was created during step 3, create a new network interface:

```console
aws ec2 create-network-interface --subnet-id <your subnet ID>
```

Attach the network interface to the EC2 instance:

```console
aws ec2 attach-network-interface --network-interface-id <your network interface ID> --instance-id <your instance ID> --device-index 1
```

## Deploy the srsRAN radio simulator

Wait for the instance to boot up and be accessible via SSH, then add it as a Juju machine:

```console
juju add-machine ssh:ubuntu@<EC2 instance IP address>
```

Note the Juju machine ID and deploy srsRAN to it:

```console
juju deploy srs-enb-ue --channel=edge --to <Machine ID>
```

## Integrate the radio simulator with Magma Access Gateway

```console
juju relate srs-enb-ue:lte-core magma-access-gateway-operator:lte-core
```
