# 07 — Testing & Verification

## Overview

This document covers the end-to-end testing and verification of the Book Review App deployment on AWS. All three tiers were tested individually and as a complete system to confirm the production architecture is working correctly.

---

## Testing Checklist

| Test | Expected Result | Status |
|------|----------------|--------|
| Public ALB DNS loads app | Books list loads | ✅ Passed |
| Book details page | Book details + reviews load | ✅ Passed |
| User registration | New user created | ✅ Passed |
| User login | JWT token received | ✅ Passed |
| Review submission | Review saved to DB | ✅ Passed |
| Web Tier EC2 healthy | 3/3 checks passed | ✅ Passed |
| App Tier EC2 healthy | 3/3 checks passed | ✅ Passed |
| Public ALB active | Internet-facing, Active | ✅ Passed |
| Internal ALB active | Internal, Active | ✅ Passed |
| web-tier-tg healthy | 1 healthy target | ✅ Passed |
| app-tier-tg healthy | 1 healthy target | ✅ Passed |
| RDS Primary available | MySQL 8.4.8, Available | ✅ Passed |
| RDS Read Replica available | Replica, Available | ✅ Passed |
| App Tier → RDS connection | Books returned from DB | ✅ Passed |
| Web Tier → Internal ALB | Books returned via ALB | ✅ Passed |

---

## Test 1 — Web Tier Direct Access

**Method:** Open Public IP in browser
```
http://54.243.168.24
```
**Expected:** Book Review App UI loads
**Result:** ✅ Passed — Book Review App loaded successfully via EC2 public IP

---

## Test 2 — Public ALB DNS Access

**Method:** Open Public ALB DNS in browser
```
http://book-review-public-alb-169792600.us-east-1.elb.amazonaws.com
```
**Expected:** Book Review App UI loads via ALB
**Result:** ✅ Passed — All three books loaded via Public ALB DNS

---

## Test 3 — App Tier Health Check

**Method:** From Web Tier EC2 terminal, curl the Internal ALB
```bash
curl http://internal-book-review-internal-alb-1773318079.us-east-1.elb.amazonaws.com:3001
```
**Expected:** API response from Node.js backend
**Result:** ✅ Passed — Returned "📚 Book Review API is running..."

---

## Test 4 — Database Connectivity

**Method:** Backend connects to RDS via Sequelize on startup
```
DB_HOST=book-review-db.cgdwgcgy8hsp.us-east-1.rds.amazonaws.com
```
**Expected:** Successful MySQL connection
**Result:** ✅ Passed — "Database 'bookreviews' connected successfully with SSL!"

---

## Test 5 — Full Stack Flow

**Method:** Open Public ALB DNS in browser and perform full user journey:

1. Visit homepage → Books list loads ✅
2. Click on a book → Book details load ✅
3. Register a new account → Registration succeeds ✅
4. Login with new account → Login succeeds ✅
5. Submit a book review → Review appears on page ✅

**Result:** ✅ Passed — Full user journey completed successfully end-to-end

---

## Architecture Verification

```
INTERNET
    │
    ▼ ✅ Public ALB DNS accessible
[book-review-public-alb-169792600.us-east-1.elb.amazonaws.com]
    │
    ▼ ✅ Web Tier healthy targets
[book-review-web-tier EC2 — 10.0.1.80]
  └── Ubuntu 24.04 | Next.js + Nginx | PM2
    │
    ▼ ✅ Internal ALB routing
[internal-book-review-internal-alb-1773318079.us-east-1.elb.amazonaws.com]
    │
    ▼ ✅ App Tier healthy targets
[book-review-app-tier EC2 — 10.0.3.168]
  └── Ubuntu 24.04 | Node.js/Express | PM2
    │
    ▼ ✅ RDS connection successful
[book-review-db.cgdwgcgy8hsp.us-east-1.rds.amazonaws.com]
  └── Primary: book-review-db (MySQL 8.4.8)
  └── Replica: book-review-db-replica
```

---

## Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/33-app-books-loading.png` | Books loading via Public ALB DNS |
| `screenshots/34-book-details-page.png` | Book details and reviews loading |
| `screenshots/35-user-registration.png` | User registration success |
| `screenshots/36-user-login.png` | User login success |
| `screenshots/37-review-submitted.png` | Review submitted successfully |
| `screenshots/38-both-ec2-running.png` | Both EC2 instances running and healthy |
| `screenshots/39-both-albs-active.png` | Both ALBs showing Active status |
| `screenshots/40-both-tgs-healthy.png` | Both target groups showing healthy |
| `screenshots/41-both-rds-available.png` | Both RDS instances showing Available |
| `screenshots/42-backend-db-connected.png` | Backend connected to RDS via PM2 |
| `screenshots/43-internal-alb-routing.png` | Internal ALB routing confirmed via curl |

---

## Issues & Fixes

### CORS Policy Error
**Issue:** Registration and login failed with "Registration failed" error in the browser.
**Root Cause:** `ALLOWED_ORIGINS` in the backend `.env` only included `http://localhost:3000` — the Public ALB DNS was not listed as an allowed origin.
**Fix:** Added the Public ALB DNS to `ALLOWED_ORIGINS` in the backend `.env` on the App Tier and restarted PM2 with `--update-env` flag.

```env
ALLOWED_ORIGINS=http://book-review-public-alb-169792600.us-east-1.elb.amazonaws.com,http://localhost:3000
```

---

### Books Not Loading — Client Side API URL
**Issue:** Books list showed "No books available" and browser network tab showed `ERR_CONNECTION_TIMED_OUT`.
**Root Cause:** `NEXT_PUBLIC_API_URL` is a client-side environment variable. The browser was trying to reach the Internal ALB directly from outside the VPC, which is impossible.
**Fix:** Set `API_URL` to empty string `""` in `api.js` so all API calls go to the same origin. Configured Nginx on the Web Tier to proxy all `/api/*` requests to the Internal ALB internally — the browser never needs to know about the Internal ALB.

```nginx
location /api/ {
    proxy_pass http://internal-book-review-internal-alb-1773318079.us-east-1.elb.amazonaws.com:3001;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

---

### App Tier Target Unhealthy
**Issue:** `app-tier-tg` showed 1 unhealthy target after Internal ALB was created.
**Root Cause:** The `app-sg` inbound rule for port 3001 only allowed traffic from `web-sg`. The Internal ALB health check requests originate from the ALB itself, not from `web-sg`, so they were being blocked.
**Fix:** Added an additional inbound rule to `app-sg` allowing port 3001 from `10.0.0.0/16` (entire VPC CIDR) so the ALB health checks can reach the App Tier.

---

### SSM Session Manager Offline in Private Subnet
**Issue:** SSM ping status showed Offline for the App Tier instance despite the IAM role being attached.
**Root Cause:** The App Tier is in a private subnet with no internet access. SSM agent could not reach AWS endpoints to register.
**Fix:** Created three VPC Interface Endpoints (`ssm`, `ssmmessages`, `ec2messages`) in the app subnets and added port 443 inbound to `app-sg` from within the VPC (`10.0.0.0/16`).

---

### No Internet Access in Private Subnet
**Issue:** `apt update` and `curl` failed with "Network is unreachable" on the App Tier instance.
**Root Cause:** Private subnets have no internet access by default. VPC Endpoints only allow SSM traffic, not general internet traffic needed for package installation.
**Fix:** Created a NAT Gateway in `web-subnet-1` (public subnet) and added a `0.0.0.0/0 → NAT Gateway` route to `private-rt`. This allows private instances to make outbound internet requests for installing packages while remaining unreachable from the internet.

> **Note:** NAT Gateway incurs hourly charges (~$0.045/hour). It was kept active during the deployment phase for package installation.

---

## Commit Reference

```
chore: complete end-to-end testing and verification of three-tier deployment
```