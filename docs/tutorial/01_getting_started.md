# 1. Getting Started

We will start by login in with AWS, creating resources that will be needed throughout the tutorial and bootstrapping a Juju controller.

## Login to AWS

Login to AWS using the AWS CLI:

```{code-block} shell
aws configure
```

You will be asked to provide your AWS credentials and the region. The rest of this tutorial assumes that the region is `us-east-2`.

## Create AWS resources

### Create a security group

Create a security group in your default AWS VPC:

```{code-block} shell
aws ec2 create-security-group --group-name "magma" --description "Allow All" --vpc-id <your VPC ID>
```

Note the `GroupId` and use it to add a wildcard rule:

```{code-block} shell
aws ec2 authorize-security-group-ingress --group-id <security group ID> --protocol -1 --port -1 --cidr 0.0.0.0/0
```

### Create a subnet

Create a subnet called **S1**:

```{code-block} shell
aws ec2 create-subnet --vpc-id <your VPC ID> --cidr-block 172.31.126.0/28 --availability-zone us-east-2a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=s1}]'
```

Make sure to use a `cidr-block` that fits into your default VPC block.

Note the `SubnetId`. You will need it to complete this tutorial.

## Bootstrap a Juju controller on AWS

Bootstrap a Juju controller on AWS:

```{code-block} shell
juju bootstrap aws/us-east-2
```
