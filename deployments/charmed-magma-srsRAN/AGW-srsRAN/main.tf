variable "cloud_name" {
    type = string
}

terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "0.4.1"
    }
  }
}

provider "juju" {}

resource "juju_model" "agw-srsran" {
  name = "agw-srsran"
  cloud {
    name   = var.cloud_name
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
