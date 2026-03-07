# Azure Deployment Notes

## Architecture
- 3-Tier deployment on Microsoft Azure
- Web Tier: Next.js + Nginx on public VM
- App Tier: Node.js/Express on private VM
- Database Tier: Azure MySQL Flexible Server

## Network Setup
- VNet: 10.0.0.0/16
- Web Subnet: 10.0.1.0/24 (public)
- App Subnet: 10.0.3.0/24 (private)
- DB Subnet: 10.0.5.0/24 (private)

## Services Used
- Azure Virtual Machines (Ubuntu 22.04)
- Azure Database for MySQL Flexible Server
- Azure Load Balancer (Public + Internal)
- Azure NAT Gateway
- Network Security Groups
- Nginx Reverse Proxy
- PM2 Process Manager
