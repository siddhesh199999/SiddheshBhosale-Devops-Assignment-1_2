output "controller_public_ip" {
  value       = aws_eip.controller.public_ip
  description = "Controller Public IP"
}

output "swarm_manager_public_ip" {
  value       = aws_eip.swarm_manager.public_ip
  description = "Swarm Manager Public IP"
}

output "swarm_worker_a_public_ip" {
  value       = aws_eip.swarm_worker_a.public_ip
  description = "Swarm Worker A Public IP"
}

output "swarm_worker_b_public_ip" {
  value       = aws_eip.swarm_worker_b.public_ip
  description = "Swarm Worker B Public IP"
}
