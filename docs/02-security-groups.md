# 02 — Security Groups

## Overview

This document covers the security group configuration for the Book Review App AWS deployment. Three security groups were created inside `book-review-vpc` to control traffic flow between tiers using the principle of least privilege. Each tier only accepts traffic from its direct upstream source — nothing more.

---

## Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| Security Group | `web-sg` | Controls traffic to Web Tier EC2 instances |
| Security Group | `app-sg` | Controls traffic to App Tier EC2 instances |
| Security Group | `db-sg` | Controls traffic to RDS MySQL instance |

---

## Security Groups Created

| Security Group | Tier | Inbound Port | Source |
|----------------|------|-------------|--------|
| `web-sg` | Web (Presentation) | 80 (HTTP) | `0.0.0.0/0` (public internet) |
| `app-sg` | App (Business Logic) | 3001 (Custom TCP) | `web-sg` only |
| `db-sg` | Database | 3306 (MySQL) | `app-sg` only |

---

## web-sg — Web Tier Security Group

- **Name:** `web-sg`
- **VPC:** `book-review-vpc`
- **Description:** Allow HTTP from internet and traffic from Public ALB

### Inbound Rules

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| HTTP | TCP | 80 | `0.0.0.0/0` | Public internet traffic |

### Outbound Rules

| Type | Protocol | Port Range | Destination |
|------|----------|------------|-------------|
| All traffic | All | All | `0.0.0.0/0` |

> The web tier is the only tier exposed to the public internet. It accepts HTTP traffic on port 80, which Nginx forwards to the Next.js frontend running locally on the EC2 instance.

---

## app-sg — App Tier Security Group

- **Name:** `app-sg`
- **VPC:** `book-review-vpc`
- **Description:** Allow traffic only from Web Tier SG on port 3001

### Inbound Rules

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| Custom TCP | TCP | 3001 | `web-sg` | Web tier traffic only |

### Outbound Rules

| Type | Protocol | Port Range | Destination |
|------|----------|------------|-------------|
| All traffic | All | All | `0.0.0.0/0` |

> The app tier is completely private. It only accepts traffic originating from instances attached to `web-sg`. No direct public access is possible. The Node.js/Express backend listens on port 3001.

---

## db-sg — Database Tier Security Group

- **Name:** `db-sg`
- **VPC:** `book-review-vpc`
- **Description:** Allow MySQL traffic only from App Tier SG

### Inbound Rules

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| MySQL/Aurora | TCP | 3306 | `app-sg` | App tier traffic only |

### Outbound Rules

| Type | Protocol | Port Range | Destination |
|------|----------|------------|-------------|
| All traffic | All | All | `0.0.0.0/0` |

> The database tier is the most restricted. Only instances attached to `app-sg` can connect to MySQL on port 3306. The RDS instance is in a private subnet and is never reachable from the internet under any circumstance.

---

## Traffic Flow Summary

```
## Traffic Flow Summary

```
INTERNET
    │
    ▼ (port 80/443)
[web-sg] → Web Tier EC2
    │
    ▼ (port 3001, source: web-sg only)
[app-sg] → App Tier EC2
    │
    ▼ (port 3306, source: app-sg only)
[db-sg]  → RDS MySQL
```

---

## Why Security Groups Are Configured This Way

- **Source-based rules, not IP-based** — Instead of allowing a CIDR range, the app and DB security groups use other security groups as their source. This means only AWS resources explicitly assigned `web-sg` or `app-sg` can communicate downstream. This is more secure and maintainable than IP-based rules.
- **Least privilege** — Each tier only opens the exact port it needs. No unnecessary ports are exposed anywhere.
- **No direct DB access** — There is no path from the internet to port 3306. An attacker would need to compromise both the web tier and the app tier before even reaching the database network boundary.
- **Outbound unrestricted** — Outbound rules are left open so EC2 instances and RDS can make outbound calls (e.g., for package installs, updates, and RDS connectivity checks during setup).

---

## Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/07-web-sg-inbound.png` | web-sg inbound rules |
| `screenshots/08-app-sg-inbound.png` | app-sg inbound rules |
| `screenshots/09-db-sg-inbound.png` | db-sg inbound rules |

---

## Troubleshooting

No issues encountered during security group setup.

---

## Commit Reference

```
chore: add security groups for web, app, and db tiers
```