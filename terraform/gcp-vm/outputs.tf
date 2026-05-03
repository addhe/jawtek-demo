# ============================================================
# Outputs
# ============================================================

output "vm_name" {
  description = "VM instance name"
  value       = google_compute_instance.vm.name
}

output "vm_id" {
  description = "VM instance ID"
  value       = google_compute_instance.vm.id
}

output "vm_zone" {
  description = "VM zone"
  value       = google_compute_instance.vm.zone
}

output "vm_machine_type" {
  description = "VM machine type"
  value       = google_compute_instance.vm.machine_type
}

output "vm_network" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "vm_subnet" {
  description = "Subnet name"
  value       = google_compute_subnetwork.subnet.name
}

output "vm_internal_ip" {
  description = "VM internal IP address"
  value       = google_compute_instance.vm.network_interface[0].network_ip
}
