# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands
- **Development**:
  - Frontend: `cd frontend && npm run dev`
  - Backend: `cd backend && node src/server.js`
- **Build**:
  - Frontend: `cd frontend && npm run build`
  - Backend: No build process (starts directly with `node`)
- **Testing**:
  - Frontend: `cd frontend && npm test`
  - Backend: `cd backend && npm test` (assuming Jest is configured)
- **Linting**:
  - Frontend: `cd frontend && npm run lint`
  - Backend: `cd backend && npm run lint`

## Project Architecture
This is a **three-tier web application** with clear separation of concerns:
1. **Frontend** (Next.js):
   - Server-side rendering
   - Dynamic routing (`/book/[id]`)
   - React Context for auth state management
   - Tailwind CSS utility-first styling

2. **Backend** (Node.js/Express):
   - REST API endpoints under `/src/routes`
   - Sequelize ORM for MySQL database
   - JWT-based authentication middleware
   - Modular structure with controllers/models separation

3. **Database** (MySQL):
   - Managed via Sequelize ORM
   - Models: `User`, `Book`, `Review`

## Key Configuration Files
- `/frontend/next.config.js`: Next.js configuration
- `/backend/.env`: Environment variables (DB credentials, ports)
- `/backend/src/config`: Database connection settings
- `/backend/src/middleware`: JWT authentication logic

## Critical Features
- JWT token-based authentication
- React Context API for global auth state
- Three-tier architecture enabling independent deployment
- Tailwind CSS for UI customization

## Deployment Considerations
Designed for containerization and cloud hosting (AWS/Azure). Includes:
- Separate frontend/backend deployment units
- CI/CD pipeline setup (mentioned in course context)
- Environment-specific configuration via `.env`

## Terraform with Azure
This project uses Terraform to provision and manage Azure infrastructure components for the Book Review App.

### Terraform Configuration Structure
```
/terraform
 ├── main.tf          # Azure resource definitions (App Service, MySQL, Networking)
 ├── variables.tf     # Configurable parameters (region, resource names, sizes)
 ├── outputs.tf       # Deployment outputs (frontend_url, backend_url, db_connection_string)
 ├── providers.tf     # Azure provider configuration and authentication
 └── backend.tf       # Terraform state storage configuration (Azure Storage)
```

### IaC Components
- **App Service Plan & Web Apps**:
  - Frontend deployed as Azure Web App (Linux container)
  - Backend deployed as separate Azure Web App
- **Azure Database for MySQL**: Flexible Server instance with auto-backup
- **Virtual Network & Subnet**: Network isolation for database
- **Azure Key Vault**: Secure secret storage for DB passwords, JWT secrets
- **Application Insights**: Monitoring and logging for both apps

### Terraform Commands
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Important Notes
- Terraform state stored in Azure Storage account with container lock
- Azure Service Principal authentication required (set via environment variables or Azure CLI)
- Database SSL enforcement enabled for secure connections
- All resources tagged with `Project = "book-review-app"` and `Environment = "production"`

### Environment Variables for Terraform
```bash
ARM_SUBSCRIPTION_ID=<azure_subscription_id>
ARM_CLIENT_ID=<service_principal_app_id>
ARM_CLIENT_SECRET=<service_principal_password>
ARM_TENANT_ID=<azure_tenant_id>
```

## Usage Notes for Claude Code
1. When modifying authentication logic, preserve JWT implementation pattern
2. For architectural changes, consider the separation of concerns between tiers
3. When adding new features, follow Next.js/Express project conventions