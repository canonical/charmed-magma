# 7. Destroying the environment

Destroy the Juju controller:

```{code-block} shell
juju kill-controller -y aws-us-east-2
```

Destroy the AWS resources:

```{code-block} shell
eksctl delete cluster --name magma-orc8r
aws ec2 terminate-instances --instance-ids <Magma Access Gateway instance ID> <srsRAN instance ID>
aws ec2 delete-network-interface --network-interface-id <Magma Access Gateway network interface ID>
aws ec2 delete-network-interface --network-interface-id <srsRAN network interface ID>
aws ec2 delete-subnet --subnet-id <S1 subnet ID>
aws ec2 delete-security-group --group-id <your security group ID>
```
