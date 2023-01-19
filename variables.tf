variable "doppler_service_token" {
  type        = string
  description = "Scoped Doppler service token used to access secrets needed for the deployment"
  sensitive   = true
}
