output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer and bastion host"
  value = aws_instance.load_balancer.public_ip
}
