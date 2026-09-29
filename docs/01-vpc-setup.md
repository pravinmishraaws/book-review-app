# 01 — VPC & Network Setup

## Overview

This document covers the complete network foundation for the Book Review App AWS deployment. A custom VPC was created with 6 subnets across 2 Availability Zones, an Internet Gateway for public internet access, and two route tables to control traffic flow between public and private tiers.

---

## Resources Created

| Resource | Name | Value |
|----------|------|-------|
| VPC | `book-review-vpc` | CIDR: `10.0.0.0/16` |
| Internet Gateway | `book-review-igw` | Attached to `book-review-vpc` |
| Public Route Table | `public-rt` | Routes `0.0.0.0/0` → IGW |
| Private Route Table | `private-rt` | Local routes only |

---

## VPC Configuration

- **Name:** `book-review-vpc`
- **CIDR Block:** `10.0.0.0/16`
- **DNS Hostnames:** Enabled ✅
- **Tenancy:** Default

> DNS hostnames must be enabled so EC2 instances receive DNS names, which are required by the Application Load Balancers.

---

## Internet Gateway

- **Name:** `book-review-igw`
- **Status:** Attached to `book-review-vpc`

The Internet Gateway is the entry point for all public internet traffic into the VPC. It is attached exclusively to the public (web) subnets via the public route table.

---

## Subnet Design

6 subnets were created across 2 Availability Zones (us-east-1a and us-east-1b) to ensure high availability across all three tiers.

| Subnet Name | Type | Availability Zone | CIDR Block | Auto-assign Public IP |
|-------------|------|-------------------|------------|----------------------|
| `web-subnet-1` | Public | us-east-1a | 10.0.1.0/24 | ✅ Enabled |
| `web-subnet-2` | Public | us-east-1b | 10.0.2.0/24 | ✅ Enabled |
| `app-subnet-1` | Private | us-east-1a | 10.0.3.0/24 | ❌ Disabled |
| `app-subnet-2` | Private | us-east-1b | 10.0.4.0/24 | ❌ Disabled |
| `db-subnet-1` | Private | us-east-1a | 10.0.5.0/24 | ❌ Disabled |
| `db-subnet-2` | Private | us-east-1b | 10.0.6.0/24 | ❌ Disabled |

> Web subnets have auto-assign public IPv4 enabled so EC2 instances in those subnets are reachable from the internet via the Public ALB. App and DB subnets are fully private — no direct internet access.

---

## Route Tables

### Public Route Table (`public-rt`)

| Destination | Target | Purpose |
|-------------|--------|---------|
| `10.0.0.0/16` | local | Internal VPC traffic |
| `0.0.0.0/0` | `book-review-igw` | Internet access for web tier |

**Associated subnets:** `web-subnet-1`, `web-subnet-2`

### Private Route Table (`private-rt`)

| Destination | Target | Purpose |
|-------------|--------|---------|
| `10.0.0.0/16` | local | Internal VPC traffic only |

**Associated subnets:** `app-subnet-1`, `app-subnet-2`, `db-subnet-1`, `db-subnet-2`

> Private subnets have no route to the internet. The app and database tiers are completely isolated from direct public access — all inbound traffic must flow through the load balancers.

---

## Architecture Diagram Reference

```
INTERNET
    │
    ▼
[Internet Gateway: book-review-igw]
    │
    ▼  (public-rt: 0.0.0.0/0 → IGW)
┌─────────────────────────────────────┐
│           book-review-vpc           │
│            10.0.0.0/16              │
│                                     │
│  Public Subnets (Web Tier)          │
│  ├── web-subnet-1 (10.0.1.0/24)     │
│  └── web-subnet-2 (10.0.2.0/24)     │
│                                     │
│  Private Subnets (App Tier)         │
│  ├── app-subnet-1 (10.0.3.0/24)     │
│  └── app-subnet-2 (10.0.4.0/24)     │
│                                     │
│  Private Subnets (DB Tier)          │
│  ├── db-subnet-1  (10.0.5.0/24)     │
│  └── db-subnet-2  (10.0.6.0/24)     │
└─────────────────────────────────────┘
```

---

## Why This Design?

- **Two AZs** — If one Availability Zone goes down, the other keeps the app running. This is a core requirement for production-grade deployments.
- **Public subnets for web tier only** — The frontend EC2s need to be reachable from the internet. Everything behind them (app and DB) stays private.
- **Private subnets for app and DB** — The Node.js backend and MySQL database are never directly exposed to the internet. All access is controlled through security groups and load balancers.
- **Separate route tables** — Public and private tiers have different routing needs. Splitting them ensures private subnets can never accidentally route traffic to the internet.

---

## Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/01-vpc-created.png` | VPC details showing name, CIDR, and Available status |
| `screenshots/02-igw-attached.png` | Internet Gateway attached to book-review-vpc |
| `screenshots/03-all-subnets-created.png` | All 6 subnets listed and filtered by book-review-vpc |
| `screenshots/04-public-route-table.png` | public-rt routes and subnet associations |
| `screenshots/05-private-route-table.png` | private-rt subnet associations |
| `screenshots/06-web-subnet-auto-ip-enabled.png` | web-subnet-1 auto-assign public IP enabled |

---

## Troubleshooting

No issues encountered during VPC setup.

---

## Commit Reference

```
chore: add VPC, subnets, IGW, and route tables for book-review-app
```