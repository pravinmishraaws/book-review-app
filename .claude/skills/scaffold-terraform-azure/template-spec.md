# Terraform Template Specification (Azure)

Generate these files in the `terraform/` directory:

**terraform/main.tf:**

- **Random suffix** resource to ensure globally unique resource names
- **Storage account** (general purpose v2) with:
  - Static website hosting enabled (index.html, 404.html)
  - Block public access = true (secure by default)
  - HTTPS traffic only enabled
  - All resources tagged with `Project` and `Environment` variables
- **Storage container** for static website assets ($web)
- **Azure CDN profile** (Standard Microsoft or Standard Verizon)
- **Azure CDN endpoint** with:
  - Storage account as origin
  - Origin host header set to storage account primary web host
  - Optional custom domain support if domain_name provided
  - All resources tagged appropriately

**terraform/variables.tf:**
- Variables for:
  - `region` (default: eastus)
  - `project_name` (default: portfolio-site)
  - `environment` (default: "production")
  - `domain_name` (default: "") - optional custom domain for CDN
  - `cdn_sku` (default: "Standard_Microsoft") - CDN provider SKU

**terraform/outputs.tf:**
- Outputs for:
  - `storage_account_name`
  - `storage_account_primary_web_host`
  - `cdn_profile_name`
  - `cdn_endpoint_hostname`
  - `static_website_url` (CDN URL)
  - `static_website_custom_domain` (if domain_name provided)

**terraform/providers.tf:**
- Azure provider with region variable
- Terraform block with required_version >= 1.5 and Azure provider source

**terraform/backend.tf:**
- Azure Storage backend block (commented out with instructions to uncomment after creating state bucket)
- Include comments explaining:
  1. First run `terraform init` without backend
  2. Create the resources
  3. Then uncomment backend and run `terraform init -migrate-state`
- Backend should use Azure Storage account with container for state
