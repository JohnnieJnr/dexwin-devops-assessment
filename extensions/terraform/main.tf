resource "terraform_data" "deployment_policy" {
  input = {
    environment   = var.environment
    public_access = var.public_access
    allowed_cidrs = var.allowed_cidrs
  }
}
