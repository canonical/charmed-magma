variable "domain" {
  type = string
}

variable "orchestrator_cloud_name" {
  type = string
}

variable "agw-srsran_cloud_name" {
  type = string
}

terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "0.4.3"
    }
  }
}

provider "juju" {}

################################################################################  
######################## MACHINE CHARMS ########################################
################################################################################

resource "juju_model" "agw-srsran" {
  name = "agw-srsran"
  cloud {
    name   = var.agw-srsran_cloud_name
  }
}

resource "juju_application" "agw" {
	name = "access-gateway"
	model = juju_model.agw-srsran.name
	charm {
		name = "magma-access-gateway-operator"
		channel = "beta"
	}
}

resource "juju_application" "srsran" {
	name = "srsran"
	model = juju_model.agw-srsran.name
	charm {
		name = "charmed-osm-srs-enb-ue"
		channel = "edge"
	}
}

################################################################################
############################ K8S CHARMS ########################################
################################################################################

resource "juju_model" "orchestrator" {
  name = "orchestrator"

  cloud {
    name   = var.orchestrator_cloud_name
  }
}

resource "juju_application" "nms-magmalte" {
  name = "nms-magmalte"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-nms-magmalte"
    channel = "beta"
  }
}

resource "juju_application" "nms-nginx-proxy" {
  name = "nms-nginx-proxy"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-nms-nginx-proxy"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-accessd" {
  name = "orc8r-accessd"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-accessd"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-analytics" {
  name = "orc8r-analytics"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-analytics"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-bootstrapper" {
  name = "orc8r-bootstrapper"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-bootstrapper"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-certifier" {
  name = "orc8r-certifier"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-certifier"
    channel = "beta"
  }
  config = {
    domain = var.domain
  }
}

resource "juju_application" "orc8r-configurator" {
  name = "orc8r-configurator"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-configurator"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-ctraced" {
  name = "orc8r-ctraced"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-ctraced"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-device" {
  name = "orc8r-device"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-device"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-directoryd" {
  name = "orc8r-directoryd"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-directoryd"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-dispatcher" {
  name = "orc8r-dispatcher"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-dispatcher"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-eventd" {
  name = "orc8r-eventd"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-eventd"
    channel = "beta"
  }
  config = {
    elasticsearch-url = "orc8r-elasticsearch:1234"
  }
}

resource "juju_application" "orc8r-ha" {
  name = "orc8r-ha"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-ha"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-lte" {
  name = "orc8r-lte"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-lte"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-metricsd" {
  name = "orc8r-metricsd"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-metricsd"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-nginx" {
  name = "orc8r-nginx"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-nginx"
    channel = "beta"
  }
  config = {
    domain = var.domain
  }
}

resource "juju_application" "orc8r-obsidian" {
  name = "orc8r-obsidian"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-obsidian"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-orchestrator" {
  name = "orc8r-orchestrator"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-orchestrator"
    channel = "beta"
  }
  config = {
    elasticsearch-url = "orc8r-elasticsearch:1234"
  }
}

resource "juju_application" "orc8r-policydb" {
  name = "orc8r-policydb"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-policydb"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-service-registry" {
  name = "orc8r-service-registry"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-service-registry"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-smsd" {
  name = "orc8r-smsd"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-smsd"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-state" {
  name = "orc8r-state"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-state"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-streamer" {
  name = "orc8r-streamer"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-streamer"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-subscriberdb" {
  name = "orc8r-subscriberdb"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-subscriberdb"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-subscriberdb-cache" {
  name = "orc8r-subscriberdb-cache"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-subscriberdb-cache"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-tenants" {
  name = "orc8r-tenants"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "magma-orc8r-tenants"
    channel = "beta"
  }
}

resource "juju_application" "orc8r-alertmanager" {
  name = "orc8r-alertmanager"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "alertmanager-k8s"
    channel = "stable"
  }
}

resource "juju_application" "orc8r-alertmanager-configurer" {
  name = "orc8r-alertmanager-configurer"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "alertmanager-configurer-k8s"
    channel = "edge"
  }
  config = {
    multitenant_label = "networkID"
  }
}

resource "juju_application" "orc8r-prometheus" {
  name = "orc8r-prometheus"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "prometheus-k8s"
    channel = "stable"
  }
}

resource "juju_application" "orc8r-prometheus-cache" {
  name = "orc8r-prometheus-cache"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "prometheus-edge-hub"
    channel = "edge"
  }
  config  = {
    metrics_count_limit = 500000
  }
}

resource "juju_application" "orc8r-prometheus-configurer" {
  name = "orc8r-prometheus-configurer"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "prometheus-configurer-k8s"
    channel = "edge"
  }
  config = {
    multitenant_label = "networkID"
  }
}

resource "juju_application" "orc8r-user-grafana" {
  name = "orc8r-user-grafana"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "grafana-k8s"
    channel = "stable"
  }
  config = {
    web_external_url = "/grafana"
    enable_auto_assign_org = "false"
  }
}

resource "juju_application" "postgresql-k8s" {
  name = "postgresql-k8s"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "postgresql-k8s"
    channel = "stable"
  }
}

resource "juju_application" "tls-certificates-operator" {
  name = "tls-certificates-operator"
  trust = true
  model = juju_model.orchestrator.name

  charm {
    name = "tls-certificates-operator"
    channel = "beta"
  }
}

resource "juju_integration" "nms-magmalte_orc8r-certifier" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.nms-magmalte.name
  }
  application {
    name     = juju_application.orc8r-certifier.name
  }
}

resource "juju_integration" "nms-magmalte_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.nms-magmalte.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "nms-nginx-proxy_orc8r-certifier" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.nms-nginx-proxy.name
  }
  application {
    name     = juju_application.orc8r-certifier.name
  }
}

resource "juju_integration" "name-nginx-proxy_nms-magmalte" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.nms-nginx-proxy.name
    endpoint = "magma-nms-magmalte"
  }
  application {
    name     = juju_application.nms-magmalte.name
    endpoint = "magma-nms-magmalte"
  }
}

resource "juju_integration" "orc8r-accessd_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-accessd.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-alertmanager_orc8r-alertmanager-configurer" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-alertmanager.name
    endpoint = "remote-configuration"
  }
  application {
    name     = juju_application.orc8r-alertmanager-configurer.name
    endpoint = "alertmanager"
  }
}

resource "juju_integration" "orc8r-certifier_tls-certificates-operator" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-certifier.name
  }
  application {
    name     = juju_application.tls-certificates-operator.name
  }
}

resource "juju_integration" "orc8r-certifier_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-certifier.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-configurator_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-configurator.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-ctraced_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-ctraced.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-device_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-device.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-directoryd_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-directoryd.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-lte_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-lte.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-metricsd_orc8r-alertmanager" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-metricsd.name
    endpoint = "alertmanager-k8s"
  }
  application {
    name     = juju_application.orc8r-alertmanager.name
    endpoint = "alerting"
  }
}

resource "juju_integration" "orc8r-metricsd_orc8r-alertmanager-configurer" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-metricsd.name
    endpoint = "alertmanager-configurer-k8s"
  }
  application {
    name     = juju_application.orc8r-alertmanager-configurer.name
    endpoint = "alertmanager-configurer"
  }
}

resource "juju_integration" "orc8r-metricsd_orc8r-orchestrator" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-metricsd.name
    endpoint = "magma-orc8r-orchestrator"
  }
  application {
    name     = juju_application.orc8r-orchestrator.name
    endpoint = "magma-orc8r-orchestrator"
  }
}

resource "juju_integration" "orc8r-metricsd_orc8r-prometheus" {
  model = juju_model.orchestrator.name
  application {
    name = juju_application.orc8r-metricsd.name
    endpoint = "magma-orc8r-orchestrator"
  }
  application {
    name = juju_application.orc8r-prometheus.name
    endpoint = "self-metrics-endpoint"
  }
}

resource "juju_integration" "orc8r-metricsd_orc8r-prometheus-configurer" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-metricsd.name
    endpoint = "prometheus-configurer-k8s"
  }
  application {
    name     = juju_application.orc8r-prometheus-configurer.name
    endpoint = "prometheus-configurer"
  }
}

resource "juju_integration" "orc8r-nginx_orc8r-bootstrapper" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-nginx.name
    endpoint = "magma-orc8r-bootstrapper"
  }
  application {
    name     = juju_application.orc8r-bootstrapper.name
    endpoint = "magma-orc8r-bootstrapper"
  }
}

resource "juju_integration" "orc8r-nginx_orc8r-certifier" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-nginx.name
    endpoint = "cert-certifier"
  }
  application {
    name     = juju_application.orc8r-certifier.name
    endpoint = "cert-certifier"
  }
}

resource "juju_integration" "orc8r-nginx_orc8r-certifier--cert-controller" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-nginx.name
    endpoint = "cert-controller"
  }
  application {
    name     = juju_application.orc8r-certifier.name
    endpoint = "cert-controller"
  }
}

resource "juju_integration" "orc8r-nginx_orc8r-certifier--cert-root-ca" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-nginx.name
    endpoint = "cert-root-ca"
  }
  application {
    name     = juju_application.orc8r-certifier.name
    endpoint = "cert-root-ca"
  }
}

resource "juju_integration" "orc8r-nginx_orc8r-obsidian" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-nginx.name
    endpoint = "magma-orc8r-obsidian"
  }
  application {
    name     = juju_application.orc8r-obsidian.name
    endpoint = "magma-orc8r-obsidian"
  }
}

resource "juju_integration" "orc8r-orchestrator_orc8r-certifier" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-orchestrator.name
    endpoint = "cert-admin-operator"
  }
  application {
    name     = juju_application.orc8r-certifier.name
    endpoint = "cert-admin-operator"
  }
}

resource "juju_integration" "orc8r-orchestrator_orc8r-certifier--magma-orc8r-certifier" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-orchestrator.name
    endpoint = "magma-orc8r-certifier"
  }
  application {
    name     = juju_application.orc8r-certifier.name
    endpoint = "magma-orc8r-certifier"
  }
}

resource "juju_integration" "orc8r-orchestrator_orc8r-accessd" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-orchestrator.name
    endpoint = "magma-orc8r-accessd"
  }
  application {
    name     = juju_application.orc8r-accessd.name
    endpoint = "magma-orc8r-accessd"
  }
}

resource "juju_integration" "orc8r-orchestrator_orc8r-service-registry" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-orchestrator.name
    endpoint = "magma-orc8r-service-registry"
  }
  application {
    name     = juju_application.orc8r-service-registry.name
    endpoint = "magma-orc8r-service-registry"
  }
}

resource "juju_integration" "orc8r-orchestrator_orc8r-prometheus-cache" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-orchestrator.name
    endpoint = "metrics-endpoint"
  }
  application {
    name     = juju_application.orc8r-prometheus-cache.name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "orc8r-policydb_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-policydb.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-prometheus_orc8r-alertmanager" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-prometheus.name
    endpoint = "alertmanager"
  }
  application {
    name     = juju_application.orc8r-alertmanager.name
    endpoint = "alerting"
  }
}

resource "juju_integration" "orc8r-prometheus_orc8r-prometheus-cache" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-prometheus.name
    endpoint = "metrics-endpoint"
  }
  application {
    name     = juju_application.orc8r-prometheus-cache.name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "orc8r-prometheus_orc8r-prometheus-cache--metrics-endpoint" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-prometheus.name
    endpoint = "metrics-endpoint"
  }
  application {
    name     = juju_application.orc8r-prometheus-cache.name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "orc8r-smsd_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-smsd.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-state_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-state.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-subscriberdb-cache_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-subscriberdb-cache.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-subscriberdb_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-subscriberdb.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-tenants_postgresql-k8s" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-tenants.name
    endpoint = "db"
  }
  application {
    name     = juju_application.postgresql-k8s.name
    endpoint = "db"
  }
}

resource "juju_integration" "orc8r-user-grafana_orc8r-prometheus" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-user-grafana.name
    endpoint = "grafana-source"
  }
  application {
    name     = juju_application.orc8r-prometheus.name
    endpoint = "grafana-source"
  }
}

resource "juju_integration" "orc8r-user-grafana_nms-magmalte" {
  model = juju_model.orchestrator.name
  application {
    name     = juju_application.orc8r-user-grafana.name
    endpoint = "grafana-auth"
  }
  application {
    name     = juju_application.nms-magmalte.name
    endpoint = "grafana-auth"
  }
}
