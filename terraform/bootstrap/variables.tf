variable "location" {
  type        = string
  description = "Azure region for the Terraform state resources."
  default     = "eastus"
}

variable "tfstate_storage_account_name" {
  type        = string
  description = "Globally unique Azure Storage Account name for Terraform state."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.tfstate_storage_account_name))
    error_message = "Storage account name must be 3-24 chars, lowercase letters and numbers only."
  }
}

variable "terraform_principal_id" {
  type        = string
  description = "Object ID of the Terraform managed identity service principal."
}
