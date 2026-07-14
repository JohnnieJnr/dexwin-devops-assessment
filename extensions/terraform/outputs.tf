output "deployment_policy" {
  description = "The deployment policy selected by the caller."
  value       = terraform_data.deployment_policy.output
}
