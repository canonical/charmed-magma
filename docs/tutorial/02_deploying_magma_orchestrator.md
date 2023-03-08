# 2. Deploying Magma Orchestrator

In this section, we will deploy Magma Orchestrator on AWS managed Kubernetes service (EKS) using Juju.

!!! note
    The following steps assume that you have a domain name registered with a DNS provider and that you have 
    a hosted zone in AWS's Route53 associated with this domain. Everywhere you see `<your domain name>` in the
    following steps, you should replace it with your domain name.

## Create a Kubernetes cluster

Create a Kubernetes cluster on AWS using `eksctl`:

```console
eksctl create cluster --name magma-orc8r --region us-east-2 --node-type t2.xlarge
```

You can check that the cluster is running by running `kubectl` commands (ex. `kubectl get nodes`).

Add the Kubernetes cloud to Juju:

```console
juju add-k8s eks-magma-orc8r --client --controller aws-us-east-2
```

## Deploy Magma Orchestrator

Create a Juju model:

```console
juju add-model orc8r eks-magma-orc8r/us-east-2
```

Create a file called `overlay.yaml` in your current working directory and place the following content in it:

```yaml title="overlay.yaml"
applications:
  orc8r-certifier:
    options:
      domain: <your domain name>
  orc8r-nginx:
    options:
      domain: <your domain name>
  tls-certificates-operator:
    options:
      generate-self-signed-certificates: true
      ca-common-name: rootca.<your domain name>
```

Deploy Magma's Orchestrator with this overlay file:

```console
juju deploy magma-orc8r --overlay overlay.yaml --trust
```

You can see the deployment's status by running `juju status`. The deployment is completed when all units are in the `Active-Idle` state.

```console
ubuntu@host:~$ juju status
Model               Controller                          Cloud/Region                        Version  SLA          Timestamp
magma-orchestrator  magma-orchestrator-k8s-localhost  magma-orchestrator-k8s/localhost  2.9.35   unsupported  18:19:48-04:00

[...]

Unit                              Workload  Agent  Address      Ports     Message
nms-magmalte/0*                   active    idle   10.1.50.73             
nms-nginx-proxy/0*                active    idle   10.1.50.75             
orc8r-accessd/0*                  active    idle   10.1.50.76             
orc8r-alertmanager-configurer/0*  active    idle   10.1.50.81             
orc8r-alertmanager/0*             active    idle   10.1.50.77             
orc8r-analytics/0*                active    idle   10.1.50.82             
orc8r-bootstrapper/0*             active    idle   10.1.50.84             
orc8r-certifier/0*                active    idle   10.1.50.87             
orc8r-configurator/0*             active    idle   10.1.50.88             
orc8r-ctraced/0*                  active    idle   10.1.50.89             
orc8r-device/0*                   active    idle   10.1.50.90             
orc8r-directoryd/0*               active    idle   10.1.50.91             
orc8r-dispatcher/0*               active    idle   10.1.50.92             
orc8r-eventd/0*                   active    idle   10.1.50.94             
orc8r-ha/0*                       active    idle   10.1.50.95             
orc8r-lte/0*                      active    idle   10.1.50.97             
orc8r-metricsd/0*                 active    idle   10.1.50.99             
orc8r-nginx/0*                    active    idle   10.1.50.102            
orc8r-obsidian/0*                 active    idle   10.1.50.103            
orc8r-orchestrator/0*             active    idle   10.1.50.106            
orc8r-policydb/0*                 active    idle   10.1.50.107            
orc8r-prometheus-cache/0*         active    idle   10.1.50.110            
orc8r-prometheus-configurer/0*    active    idle   10.1.50.116            
orc8r-prometheus/0*               active    idle   10.1.50.72             
orc8r-service-registry/0*         active    idle   10.1.50.111            
orc8r-smsd/0*                     active    idle   10.1.50.112            
orc8r-state/0*                    active    idle   10.1.50.115            
orc8r-streamer/0*                 active    idle   10.1.50.117            
orc8r-subscriberdb-cache/0*       active    idle   10.1.50.119            
orc8r-subscriberdb/0*             active    idle   10.1.50.118            
orc8r-tenants/0*                  active    idle   10.1.50.120            
orc8r-user-grafana/0*             active    idle   10.1.50.123            
postgresql-k8s/0*                 active    idle   10.1.50.126  5432/TCP  Pod configured
tls-certificates-operator/0*      active    idle   10.1.50.121            
```

## Configure Route53

Retrieve the list of services for which DNS records are needed:

```console
juju run-action orc8r-orchestrator/leader get-load-balancer-services --wait
```

The result should look like so:

```console
ubuntu@host:~$ juju run-action orc8r-orchestrator/leader get-load-balancer-services --wait
unit-orc8r-orchestrator-0:
  UnitId: orc8r-orchestrator/0
  id: "2"
  results:
    fluentd: a13611fd67ae84df5bd40c4c7fe892d5-1909378219.us-east-2.elb.amazonaws.com
    nginx-proxy: a7b65619cbf8443feb05910823b6c42b-748407990.us-east-2.elb.amazonaws.com
    orc8r-bootstrap-nginx: ab4feaf807c9440b8b021395f0422b26-1385734990.us-east-2.elb.amazonaws.com
    orc8r-clientcert-nginx: ac63855b699064f5b825e707cfe290f0-1144570992.us-east-2.elb.amazonaws.com
    orc8r-nginx-proxy: a6ae77105db624f06bb37f18843db925-911888461.us-east-2.elb.amazonaws.com
  status: completed
  timing:
    completed: 2023-03-08 19:26:46 +0000 UTC
    enqueued: 2023-03-08 19:26:44 +0000 UTC
    started: 2023-03-08 19:26:45 +0000 UTC
```

The hostnames associated to each service will differ from those shown here.

Create a file named `dns.json` with the following content:

```json title="dns.json"
{
  "Comment": "CREATE CNAME records",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "bootstrapper-controller.<your domain name>",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "ab4feaf807c9440b8b021395f0422b26-1385734990.us-east-2.elb.amazonaws.com"
          }
        ]
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "api.<your domain name>",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "a6ae77105db624f06bb37f18843db925-911888461.us-east-2.elb.amazonaws.com"
          }
        ]
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "controller.<your domain name>",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "ac63855b699064f5b825e707cfe290f0-1144570992.us-east-2.elb.amazonaws.com"
          }
        ]
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "*.nms.<your domain name>",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "a7b65619cbf8443feb05910823b6c42b-748407990.us-east-2.elb.amazonaws.com"
          }
        ]
      }
    }
  ]
}
```

!!! note
    Replace each resource record value with the ones received from the previous step using the following Service/Hostname scheme:

    | Service                                | Hostname                              | 
    |----------------------------------------|---------------------------------------|
    | `<orc8r-bootstrap-nginx External IP>`  | `bootstrapper-controller.<your domain name>` | 
    | `<orc8r-nginx-proxy External IP>`      | `api.<your domain name>`                     | 
    | `<orc8r-clientcert-nginx External IP>` | `controller.<your domain name>`              | 
    | `<nginx-proxy External IP>`            | `*.nms.<your domain name>`                   | 


Create the CNAME records in Route53:

```console
aws route53 change-resource-record-sets --hosted-zone-id <your hosted zone ID> --change-batch file://dns.json
```

Now, navigate to `https://master.nms.<your domain name>`, you should receive a warning because we are
using self-signed-certificates, click on "Proceed".

## Verifying the deployment

Get the master organization's username and password:

```console
juju run-action nms-magmalte/leader get-master-admin-credentials --wait
```

Note the `admin-username` and `admin-password` values.

Confirm successful deployment by visiting `https://master.nms.<your domain name>` and logging in
with the `admin-username` and `admin-password` outputted here.
