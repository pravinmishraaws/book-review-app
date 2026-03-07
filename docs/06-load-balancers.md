# 06 — Load Balancer Configuration

## Overview

This document covers the setup of two Application Load Balancers (ALBs) for the Book Review App AWS deployment. A Public ALB handles incoming internet traffic to the Web Tier, and an Internal ALB routes traffic from the Web Tier to the App Tier.

---

## Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| Public ALB | `book-review-public-alb` | Routes internet traffic to Web Tier EC2 |
| Internal ALB | `book-review-internal-alb` | Routes Web Tier traffic to App Tier EC2 |
| Target Group | `web-tier-tg` | Web Tier EC2 instances |
| Target Group | `app-tier-tg` | App Tier EC2 instances |

---

## Public ALB Configuration

- **Name:** `book-review-public-alb`
- **Scheme:** Internet-facing
- **IP address type:** IPv4
- **VPC:** `book-review-vpc`
- **Subnets:** `web-subnet-1` (us-east-1a), `web-subnet-2` (us-east-1b)
- **Security Group:** `web-sg`

### Listener
| Protocol | Port | Default Action |
|----------|------|----------------|
| HTTP | 80 | Forward to `web-tier-tg` |

### Target Group (`web-tier-tg`)
- **Target type:** Instances
- **Protocol:** HTTP
- **Port:** 80
- **VPC:** `book-review-vpc`
- **Health check path:** `/`
- **Registered targets:** `book-review-web-tier` EC2

---

## Internal ALB Configuration

- **Name:** `book-review-internal-alb`
- **Scheme:** Internal
- **IP address type:** IPv4
- **VPC:** `book-review-vpc`
- **Subnets:** `app-subnet-1` (us-east-1a), `app-subnet-2` (us-east-1b)
- **Security Group:** `app-sg`

### Listener
| Protocol | Port | Default Action |
|----------|------|----------------|
| HTTP | 3001 | Forward to `app-tier-tg` |

### Target Group (`app-tier-tg`)
- **Target type:** Instances
- **Protocol:** HTTP
- **Port:** 3001
- **VPC:** `book-review-vpc`
- **Health check path:** `/`
- **Registered targets:** `book-review-app-tier` EC2

---

## Public Entry Point

**Public ALB DNS:** *(To be updated after deployment)*

---

## Architecture Diagram Reference

```
INTERNET
    │
    ▼ (port 80)
[book-review-public-alb]  ← Internet-facing
    │
    ▼ (port 80, target: web-tier-tg)
[Web Tier EC2s]
  └── web-subnet-1 (us-east-1a)
  └── web-subnet-2 (us-east-1b)
    │
    ▼ (port 3001)
[book-review-internal-alb]  ← Internal only
    │
    ▼ (port 3001, target: app-tier-tg)
[App Tier EC2s]
  └── app-subnet-1 (us-east-1a)
  └── app-subnet-2 (us-east-1b)
    │
    ▼ (port 3306)
[RDS MySQL]
```

---

## Why This Design?

- **Public ALB** — Acts as the single public entry point for all web traffic. It distributes requests across Web Tier EC2s in multiple AZs for high availability.
- **Internal ALB** — The App Tier has no public IP. The Internal ALB is the only way for the Web Tier to communicate with the backend, keeping the app tier fully private.
- **Separate security groups** — The Public ALB uses the web-sg while the Internal ALB uses the app-sg, enforcing strict tier-to-tier access control.
- **Health checks** — ALBs automatically stop routing to unhealthy instances and resume when they recover.

---

## Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/22-public-alb-created.png` | Public ALB showing Active status and DNS name |
| `screenshots/23-public-alb-targets.png` | web-tier-tg showing healthy targets |
| `screenshots/24-internal-alb-created.png` | Internal ALB showing Active status |
| `screenshots/25-internal-alb-targets.png` | app-tier-tg showing healthy targets |

---

## Troubleshooting

*(To be updated if any issues are encountered)*

---

## Commit Reference

```
chore: configure public and internal ALBs with target groups for web and app tiers
```