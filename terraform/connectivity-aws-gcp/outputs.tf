output "aws_vpn_connection_id" {
  value = aws_vpn_connection.gcp.id
}

output "aws_vpn_tunnel_1_address" {
  value = aws_vpn_connection.gcp.tunnel1_address
}

output "gcp_vpn_tunnel_self_link" {
  value = google_compute_vpn_tunnel.aws_tunnel_1.self_link
}

output "gcp_vpn_ip" {
  value = google_compute_address.vpn_ip.address
}
