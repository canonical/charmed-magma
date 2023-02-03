# Integrate Charmed Magma Orchestrator to Elasticsearch

## Requirements

 - Elasticsearch instance supporting both `HTTP` and `HTTPS` requests
 - Connectivity between the Orchestrator and the Elasticsearch

## Integration

=== "Option 1: Integration upon deployment"

    Create an `overlay.yaml` file that contains the following content:
    
    ```yaml title="overlay.yaml"
    applications:
      fluentd:
        options:
        domain: <your domain name>
        elasticsearch-url: <your elasticsearch https url>
      orc8r-certifier:
        options:
          domain: <your domain name>
      orc8r-eventd:
        options:
          elasticsearch-url: <your elasticsearch http url>
      orc8r-nginx:
        options:
          domain: <your domain name>
      tls-certificates-operator:
        options:
          generate-self-signed-certificates: true
          ca-common-name: rootca.<your domain name>
    ```
    
    Deploy `Charmed Magma Orchestrator` as described in [Deploy Charmed Magma Orchestrator](deploy_charmed_magma_orchestrator.md)

=== "Option 2: Integration to a running Orchestrator instance"

    Configure `elasticsearch-url` in the `fluentd` charm:
    
    ```bash
    juju config fluentd elasticsearch-url=<your elasticsearch https url>
    ```
    
    Configure `elasticsearch-url` in the `orc8r-eventd` charm:
    
    ```bash
    juju config orc8r-eventd elasticsearch-url=<your elasticsearch http url>
    ```

    Confirm changes by visiting `https://<your org name>.nms.<your domain>` and checking 
    the `Events` chart of your network's dashboard.
