---
name: scaffold-terraform-azure
description: Generates a three-tier Azure infrastructure scaffold using Terraform for a Book Review System. Use tools: [read_file, write_file, list_files, search_files, run_terminal_command]
argument-hint: "[--env <development|production>]"
user-invocable: true
---


# Body: Instruction Logic

When this command is executed, generate a complete Terraform project for a three-tier architecture with the following requirements:

## 1. Project Context
- **System**: Book Review Application.
- **Frontend**: Next.js (Web App for Containers or Code).
- **Backend**: Node.js/Express (REST API).
- **Database**: Azure Database for MySQL - Flexible Server.

## 2. Infrastructure Requirements
Generate HCL (HashiCorp Configuration Language) that includes:

### Networking & Security
- **Virtual Network (VNet)**: Subnets for Frontend, Backend, and Database.
- **Azure Key Vault**: To store `DB_PASSWORD`, `JWT_SECRET`, and sensitive App Settings.
- **Managed Identity**: Use User-Assigned Managed Identity for the App Services to access Key Vault.

### Compute Tier
- **App Service Plan**: Linux-based (e.g., B1 for dev, P1v2 for prod).
- **Web Apps**: 
    - `frontend`: Configured for Next.js SSR.
    - `backend`: Configured for Node.js, with environment variables pointing to the MySQL host.

### Data Tier
- **MySQL Flexible Server**: 
    - Version 8.0.
    - Private DNS integration within the VNet.
    - High Availability (HA) enabled if `--env production` is used.

## 3. Standard Output Files
Always generate the following file structure:
- `main.tf`: Provider setup and resource definitions.
- `variables.tf`: Input variables for `location`, `resource_group`, and `tags`.
- `outputs.tf`: Exported Web App URLs and Database FQDN.
- `terraform.tfvars.example`: Example values for the variables.

## 4. Operational Best Practices
- Enable **Application Insights** for both the Frontend and Backend.
- Enforce **HTTPS** only and **Minimum TLS 1.2**.
- Use `depends_on` where necessary to ensure the Database and Key Vault exist before the App Services try to pull configs.