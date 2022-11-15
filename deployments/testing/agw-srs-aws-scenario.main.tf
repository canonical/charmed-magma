# TODO: Review whole template.
# TODO: Change instance types from free tier, to the actual required ones.
# TODO: AGW kernel downgrade.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.38.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  mappings = {
    RegionMap = {
      af-south-1 = {
        Ubuntu2004LTS = "ami-042995beac9ec5140"
      }
      ap-east-1 = {
        Ubuntu2004LTS = "ami-07b3aa6c08b0caae1"
      }
      ap-northeast-1 = {
        Ubuntu2004LTS = "ami-0d745f1ee4bb88b89"
      }
      ap-northeast-2 = {
        Ubuntu2004LTS = "ami-05a5333b72d3d1c93"
      }
      ap-northeast-3 = {
        Ubuntu2004LTS = "ami-0eb4557358e2c9386"
      }
      ap-south-1 = {
        Ubuntu2004LTS = "ami-0340ea71c538887c3"
      }
      ap-southeast-1 = {
        Ubuntu2004LTS = "ami-0fbb51b4aa5671449"
      }
      ap-southeast-2 = {
        Ubuntu2004LTS = "ami-030a8d0e06463671c"
      }
      ap-southeast-3 = {
        Ubuntu2004LTS = "ami-029497464bf11fc26"
      }
      ca-central-1 = {
        Ubuntu2004LTS = "ami-0ab6f6340b2a4fb77"
      }
      cn-north-1 = {
        Ubuntu2004LTS = "ami-0741e7b8b4fb0001c"
      }
      cn-northwest-1 = {
        Ubuntu2004LTS = "ami-0883e8062ff31f727"
      }
      eu-central-1 = {
        Ubuntu2004LTS = "ami-0d0dd86aa7fe3c8a9"
      }
      eu-north-1 = {
        Ubuntu2004LTS = "ami-051a4a0c60c88f085"
      }
      eu-south-1 = {
        Ubuntu2004LTS = "ami-0da797cba39f716ea"
      }
      eu-west-1 = {
        Ubuntu2004LTS = "ami-04e2e94de097d3986"
      }
      eu-west-2 = {
        Ubuntu2004LTS = "ami-08d3a4ad06c8a70fe"
      }
      eu-west-3 = {
        Ubuntu2004LTS = "ami-018de3a6e45331551"
      }
      me-central-1 = {
        Ubuntu2004LTS = "ami-0dd8d47397d44ff85"
      }
      me-south-1 = {
        Ubuntu2004LTS = "ami-057c0cd91677477f8"
      }
      sa-east-1 = {
        Ubuntu2004LTS = "ami-07e7afb5e1e58e8da"
      }
      us-east-1 = {
        Ubuntu2004LTS = "ami-01d08089481510ba2"
      }
      us-east-2 = {
        Ubuntu2004LTS = "ami-0066d036f9777ec38"
      }
      us-west-1 = {
        Ubuntu2004LTS = "ami-064562725417500be"
      }
      us-west-2 = {
        Ubuntu2004LTS = "ami-0e6dff8bde9a09539"
      }
    }
  }
}

variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access into the resources"
  type = string
}

variable "aws_region" {
  description = "Region to deploy resources in"
  type = string
}

resource "aws_vpc" "agw_srs_vpc" {
  cidr_block = "10.0.0.0/16"
  // enable_dns_hostnames = true // Do we need it? What it is?
  tags = {
    Key = "Name"
    Value = "AgwSrsVPC"
  }
}

resource "aws_subnet" "s1_srs_public_subnet" {
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-1c"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.agw_srs_vpc.id
  tags = {
    Key = "Name"
    Value = "S1SrsSubnet - us-west-1c"
  }
}

resource "aws_subnet" "agw_public_subnet" {
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1c"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.agw_srs_vpc.id
  tags = {
    Key = "Name"
    Value = "AgwSubnet - us-west-1c"
  }
}

resource "aws_internet_gateway" "agw_srs_igw" {
  vpc_id = aws_vpc.agw_srs_vpc.id
  tags = {
    Key = "Name"
    Value = "AgwSrsIGW"
  }
}

resource "aws_network_acl" "agw_srs_network_acl" {
  vpc_id = aws_vpc.agw_srs_vpc.id
  tags = {
    Key = "Name"
    Value = "AgwNetworkACL"
  }
}

resource "aws_route_table" "agw_srs_route_public" {
  vpc_id = aws_vpc.agw_srs_vpc.id
  tags = {
    Key = "Name"
    Value = "AgwSrsRoutePublic"
  }
}

resource "aws_instance" "agwec2_instance" {
  ami = local.mappings["RegionMap"][var.aws_region]["Ubuntu2004LTS"] // Manually changed
  instance_type = "t2.micro"
  key_name = var.key_name
  monitoring = false
  user_data = "echo hello world"
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 40
  }
  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.agws_gi_network_interface.id
  }
  network_interface {
      network_interface_id = aws_network_interface.agws1_network_interface.id
      device_index = 1
  }
  tags = {
    Key = "Name"
    Value = "AGWEC2Instance"
  }
}

resource "aws_network_interface" "agws_gi_network_interface" {
  description = "AGW SGi network interface (internet access)."
  security_groups = [aws_security_group.sg_agw_sgi.id]
  subnet_id = aws_subnet.agw_public_subnet.id
  tags = {
    Key = "Name"
    Value = "AGWS1NetworkInterface"
  }
}

// TODO: Make sure we're attaching the EIP to the SGi interface
resource "aws_eip" "eips_gi" {
  tags = {
      Key = "Name"
      Value = "SGi Elastic IP"
  }
}

resource "aws_eip_association" "eips_gi_association" {
  allocation_id = aws_eip.eips_gi.allocation_id
  network_interface_id = aws_network_interface.agws_gi_network_interface.id
}

resource "aws_network_interface" "agws1_network_interface" {
  description = "AGW S1 network interface."
  security_groups = [aws_security_group.s_gsrs.id] // TODO: change network interface
  subnet_id = aws_subnet.s1_srs_public_subnet.id
  tags = {
    Key = "Name"
    Value = "AGWS1NetworkInterface"
  }
}

resource "aws_instance" "srs_ec2_instance" {
  instance_type = "t2.micro"
  ami = local.mappings["RegionMap"][var.aws_region]["Ubuntu2004LTS"]
  key_name = var.key_name
  monitoring = false
  user_data = "echo hello world"
  network_interface {
    device_index = "0"
    network_interface_id = aws_network_interface.srs_network_interface.id
  }
  tags = {
    Key = "Name"
    Value = "SrsEC2Instance"
  }
}

resource "aws_network_interface" "srs_network_interface" {
  description = "srs network interface."
  security_groups = [aws_security_group.s_gsrs.id]
  subnet_id = aws_subnet.s1_srs_public_subnet.id
  tags = {
    Key = "Name"
    Value = "srsNetworkInterface"
  }
}

resource "aws_security_group" "s_gsrs" {
  description = "Srs - S1 ifaces security group"
  vpc_id = aws_vpc.agw_srs_vpc.id
  ingress {
    description = "Allow all traffic to srs"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all from srs"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Key = "Name"
    Value = "SrsHostSecurityGroup"
  }
}

resource "aws_security_group" "sg_agw_sgi" {
  description = "SGi AGW iface security group"
  vpc_id = aws_vpc.agw_srs_vpc.id
  ingress {
    description = "Allow all traffic to agw"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all from agw"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Key = "Name"
    Value = "SrsHostSecurityGroup"
  }
}

resource "aws_network_acl" "nacl_entry1" {
  vpc_id = aws_vpc.agw_srs_vpc.id
  egress {
    from_port = 0
    to_port = 0
    rule_no = 100
    action = "allow"
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
  }
}

// Duplicated with the resource above?
resource "aws_network_acl" "nacl_entry2" {
  vpc_id = aws_vpc.agw_srs_vpc.id
  egress {
    from_port = 0
    to_port = 0
    rule_no = 200
    action = "allow"
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
  } 
}

resource "aws_network_acl_association" "subnetacl_s1_srs" {
  network_acl_id = aws_network_acl.agw_srs_network_acl.id
  subnet_id = aws_subnet.s1_srs_public_subnet.id
}

resource "aws_network_acl_association" "subnetacl_srs" {
  network_acl_id = aws_network_acl.agw_srs_network_acl.id
  subnet_id = aws_subnet.agw_public_subnet.id
}

resource "aws_route_table_association" "subnet_route_public_s1_srs" {
  route_table_id = aws_route_table.agw_srs_route_public.id
  subnet_id = aws_subnet.s1_srs_public_subnet.id
}

resource "aws_route_table_association" "subnet_route_public_agw" {
  route_table_id = aws_route_table.agw_srs_route_public.id
  subnet_id = aws_subnet.agw_public_subnet.id
}

resource "aws_route" "publicroute" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.agw_srs_route_public.id
  gateway_id = aws_internet_gateway.agw_srs_igw.id
}
