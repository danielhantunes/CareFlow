locals {
  shared_secret = var.vpn_shared_secret != "" ? var.vpn_shared_secret : random_password.vpn_shared[0].result
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "random_password" "vpn_shared" {
  count  = var.vpn_shared_secret == "" ? 1 : 0
  length = 32

  special = false
}

data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    bucket = var.aws_state_bucket
    key    = var.aws_state_key
    region = var.aws_state_region
  }
}

data "terraform_remote_state" "gcp" {
  backend = "gcs"

  config = {
    bucket = var.gcp_state_bucket
    prefix = var.gcp_state_prefix
  }
}

locals {
  aws_vpc_id             = data.terraform_remote_state.aws.outputs.vpc_id
  aws_vpc_cidr           = data.terraform_remote_state.aws.outputs.vpc_cidr
  aws_private_route_table_id = data.terraform_remote_state.aws.outputs.private_route_table_id
  aws_instance_sg_id     = data.terraform_remote_state.aws.outputs.instance_sg_id

  gcp_vpc_name      = data.terraform_remote_state.gcp.outputs.vpc_name
  gcp_vpc_self_link = data.terraform_remote_state.gcp.outputs.vpc_self_link
  gcp_subnet_cidr   = data.terraform_remote_state.gcp.outputs.subnet_cidr
}

############################
# AWS VPN Gateway + Customer Gateway
############################
resource "aws_vpn_gateway" "vgw" {
  vpc_id = local.aws_vpc_id

  tags = {
    Name       = "careflow-aws-gcp-vgw"
    managed_by = "terraform"
  }
}

resource "aws_customer_gateway" "gcp" {
  bgp_asn    = 65000
  ip_address = google_compute_address.vpn_ip.address
  type       = "ipsec.1"

  tags = {
    Name       = "careflow-gcp-cgw"
    managed_by = "terraform"
  }
}

resource "aws_vpn_connection" "gcp" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.gcp.id
  type                = "ipsec.1"
  static_routes_only  = true

  tunnel1_preshared_key = local.shared_secret
  tunnel2_preshared_key = local.shared_secret

  tags = {
    Name       = "careflow-aws-gcp-vpn"
    managed_by = "terraform"
  }
}

resource "aws_vpn_connection_route" "to_gcp" {
  vpn_connection_id      = aws_vpn_connection.gcp.id
  destination_cidr_block = local.gcp_subnet_cidr
}

resource "aws_route" "to_gcp" {
  route_table_id         = local.aws_private_route_table_id
  destination_cidr_block = local.gcp_subnet_cidr
  vpn_gateway_id         = aws_vpn_gateway.vgw.id
}

resource "aws_security_group_rule" "allow_icmp_from_gcp" {
  type              = "ingress"
  security_group_id = local.aws_instance_sg_id
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = [local.gcp_subnet_cidr]
  description       = "Allow ICMP from GCP for connectivity tests"
}

resource "aws_security_group_rule" "allow_icmp_to_gcp" {
  type              = "egress"
  security_group_id = local.aws_instance_sg_id
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = [local.gcp_subnet_cidr]
  description       = "Allow ICMP to GCP for connectivity tests"
}

############################
# GCP Classic VPN (route-based)
############################
resource "google_compute_address" "vpn_ip" {
  name   = "careflow-aws-vpn-ip"
  region = var.gcp_region
}

resource "google_compute_vpn_gateway" "vpn_gw" {
  name    = "careflow-aws-vpn-gw"
  network = local.gcp_vpc_self_link
  region  = var.gcp_region
}

resource "google_compute_forwarding_rule" "vpn_esp" {
  name        = "careflow-vpn-esp"
  region      = var.gcp_region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.vpn_gw.self_link
}

resource "google_compute_forwarding_rule" "vpn_udp500" {
  name        = "careflow-vpn-udp500"
  region      = var.gcp_region
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.vpn_gw.self_link
}

resource "google_compute_forwarding_rule" "vpn_udp4500" {
  name        = "careflow-vpn-udp4500"
  region      = var.gcp_region
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.vpn_gw.self_link
}

resource "google_compute_vpn_tunnel" "aws_tunnel_1" {
  name               = "careflow-aws-tunnel-1"
  region             = var.gcp_region
  target_vpn_gateway = google_compute_vpn_gateway.vpn_gw.self_link
  peer_ip            = aws_vpn_connection.gcp.tunnel1_address
  shared_secret      = local.shared_secret
  ike_version        = 1

  local_traffic_selector  = [local.gcp_subnet_cidr]
  remote_traffic_selector = [local.aws_vpc_cidr]

  depends_on = [
    google_compute_forwarding_rule.vpn_esp,
    google_compute_forwarding_rule.vpn_udp500,
    google_compute_forwarding_rule.vpn_udp4500
  ]
}

resource "google_compute_route" "to_aws" {
  name       = "careflow-to-aws"
  network    = local.gcp_vpc_self_link
  dest_range = local.aws_vpc_cidr
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.aws_tunnel_1.self_link
}

resource "google_compute_firewall" "allow_icmp_from_aws" {
  name    = "careflow-allow-icmp-aws"
  network = local.gcp_vpc_name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [local.aws_vpc_cidr]
  target_tags   = ["iap-ssh"]

  allow {
    protocol = "icmp"
  }
}
