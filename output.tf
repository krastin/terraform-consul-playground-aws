output "HOSTS" {
  value = join(",", concat(aws_instance.consul-client.*.public_ip,aws_instance.consul-server.*.public_ip))
  description = "all consul node IPs"
  sensitive = false
}