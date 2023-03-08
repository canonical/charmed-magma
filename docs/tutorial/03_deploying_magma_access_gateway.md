# 3. Deploying Magma Access Gateway

## Create an instance on AWS

Create an AWS EC2 instance running Ubuntu 20.04:

```console
aws ec2 run-instances \
  --security-group-ids <your security group> \
  --image-id ami-0568936c8d2b91c4e \
  --count 1 \
  --instance-type t2.xlarge \
  --key-name <your ssh key name> \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=magma-access-gateway}]' \
  --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 50 } } ]"
```

Replace the security group ID with one that allows SSH access and note the instance ID, you will need it later.

## Attach a secondary network interface to the instance

Create a subnet called `S1`:

```console
aws ec2 create-subnet --vpc-id <your VPC ID> --cidr-block 172.31.126.0/28 --availability-zone us-east-2a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=s1}]'
```

Note the subnet ID and use it in the following command:

```console
aws ec2 create-network-interface --subnet-id <your subnet ID>
```

Add a network interface using the `S1` subnet to the EC2 machine:

```console
aws ec2 attach-network-interface --network-interface-id <your network interface ID> --instance-id <your instance ID> --device-index 1
```

## Downgrade the Kernel on the instance

Unfortunately, the default kernel on the AWS Ubuntu 20.04 AMI image is too new for Magma Access Gateway to work properly. We need to downgrade it to the LTS version `5.4.0`. Please follow the instructions in this [blog post](https://discourse.ubuntu.com/t/how-to-downgrade-the-kernel-on-ubuntu-20-04-to-the-5-4-lts-version/26459)

The `GRUB_DEFAULT` entry in the GRUB menu should look like this:

```console
GRUB_DEFAULT="gnulinux-advanced-76087362-0f3b-4cbc-b635-f48618f9725b>gnulinux-5.4.0-1097-aws-advanced-76087362-0f3b-4cbc-b635-f48618f9725b"
```

## Deploy Magma Access Gateway

Create a new Juju model for machines:

```console
juju add-model edge aws/us-east-2
```

Add the AWS instance as a Juju machine:

```console
juju add-machine ssh:ubuntu@<AWS instance IP address>
```

```console
juju deploy magma-access-gateway-operator --config sgi=eth0 --config s1=eth1 --to 0
```

You can see the deployment's status by running `juju status`. The deployment is completed when 
the application is in the `Active-Idle` state. 

```console
ubuntu@host:~$ juju status
Model    Controller        Cloud/Region         Version  SLA          Timestamp
default  virtual-machines  localhost/localhost  2.9.35   unsupported  15:46:28-04:00

App                            Version  Status  Scale  Charm                          Channel  Rev  Exposed  Message
magma-access-gateway-operator           active      1  magma-access-gateway-operator  beta      14  no       

Unit                              Workload  Agent  Machine  Public address  Ports  Message
magma-access-gateway-operator/0*  active    idle   0        10.24.157.241          

Machine  State    Address        Inst id               Series  AZ  Message
0        started  10.24.157.241  manual:10.24.157.241  focal       Manually provisioned machine
```