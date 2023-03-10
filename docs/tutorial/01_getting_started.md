# 1. Getting Started

## Bootstrap a Juju controller on AWS

From your computer where you have Juju 2.9 installed, add your AWS credentials to Juju:

```console
juju add-credential aws
```

Bootstrap a Juju controller on AWS:

```console
juju bootstrap aws/us-east-2
```
