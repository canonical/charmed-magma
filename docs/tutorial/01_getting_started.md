# 1. Getting Started

## Login to AWS

Login to AWS using the `aws` CLI:

```console
aws configure
```

You will be asked to provide your AWS credentials and the region. The rest of this tutorial assumes that the region is `us-east-2`.

## Bootstrap a Juju controller on AWS

Bootstrap a Juju controller on AWS:

```console
juju bootstrap aws/us-east-2
```
