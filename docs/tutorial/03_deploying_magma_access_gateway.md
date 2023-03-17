# 3. Deploying Magma Access Gateway

## Create an EC2 instance on AWS

### Create a security group for allowing SSH access

Create a security group in your default VPC:

```console
aws ec2 create-security-group --group-name "demo" --description "Allow SSH access" --vpc-id <your VPC ID>
```

Note the `GroupId` and use it to add a rule that allows SSH access:

```console
aws ec2 authorize-security-group-ingress --group-id <security group ID> --protocol -1 --port -1 --cidr 0.0.0.0/0
```

### Create an instance on AWS

Create an AWS EC2 instance running Ubuntu 20.04:

```console
aws ec2 run-instances \
  --security-group-ids <your security group ID> \
  --image-id ami-0568936c8d2b91c4e \
  --count 1 \
  --instance-type t2.xlarge \
  --key-name <your ssh key name> \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=magma-access-gateway}]' \
  --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 50 } } ]"
```

Replace `<your security group ID>` with the Security Group ID created in the step before and replace `<your ssh key name>` with the name of your ssh key.

Note the `InstanceId` of the created instance and use it to retrieve its public IP address:

```console
aws ec2 describe-instances --filters "Name=instance-id,Values=<your instance ID>" --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text
```

Note this address, you will need it very soon.

### Attach a secondary network interface to the instance

Create a subnet called **S1**:

```console
aws ec2 create-subnet --vpc-id <your VPC ID> --cidr-block 172.31.126.0/28 --availability-zone us-east-2a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=s1}]'
```

Note the `SubnetId` and create a network interface on this subnet:

```console
aws ec2 create-network-interface --subnet-id <your subnet ID> --group <your security group>
```

Note the `NetworkInterfaceId` and use it to attach the network interface to the EC2 instance:

```console
aws ec2 attach-network-interface --network-interface-id <your network interface ID> --instance-id <your instance ID> --device-index 1
```

### Downgrade the Kernel on the instance

Unfortunately, the default kernel on the AWS Ubuntu 20.04 AMI image is too new for Magma Access Gateway to work properly. We need to downgrade it to the LTS version `5.4.0`. SSH into the AWS instance using its public IP and follow the instructions in this [blog post](https://discourse.ubuntu.com/t/how-to-downgrade-the-kernesl-on-ubuntu-20-04-to-the-5-4-lts-version/26459). In the end, the `GRUB_DEFAULT` entry in the GRUB menu should look like `'Advanced options for Ubuntu>Ubuntu, with Linux 5.4.0-1097-aws'`.

## Deploy Magma Access Gateway

Create a new Juju model for machines:

```console
juju add-model edge aws/us-east-2
```

Wait for the instance to boot up and be accessible via SSH, then add it as a Juju machine:

```console
juju add-machine ssh:ubuntu@<EC2 instance IP address>
```

Note the Juju machine ID and deploy Magma Access Gateway to it:

```console
juju deploy magma-access-gateway-operator --config sgi=eth0 --config s1=eth1 --to <Machine ID>
```

You can see the deployment's status by running `juju status`. The deployment is completed when the application is in the `Active-Idle` state. 

```console
ubuntu@host:~$ juju status
Model  Controller     Cloud/Region   Version  SLA          Timestamp
edge   aws-us-east-2  aws/us-east-2  2.9.42   unsupported  11:41:52Z

App                            Version  Status  Scale  Charm                          Channel  Rev  Exposed  Message
magma-access-gateway-operator           active      1  magma-access-gateway-operator  stable    29  no       

Unit                              Workload  Agent  Machine  Public address  Ports  Message
magma-access-gateway-operator/0*  active    idle   0        18.188.161.66          

Machine  State    Address        Inst id               Series  AZ  Message
0        started  18.188.161.66  manual:18.188.161.66  focal       Manually provisioned machine
```
