# 04 — App Tier Deployment

## Overview

This document covers the deployment of the Node.js/Express backend on the App Tier EC2 instance. The instance runs in a private subnet and is only accessible from the Web Tier via the Internal Application Load Balancer on port 3001.

---

## Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| EC2 Instance | `book-review-app-tier` | Runs Node.js backend on port 3001 |
| IAM Role | `EC2-SSM-Role` | Enables SSM Session Manager access |
| VPC Endpoints | `ssm`, `ssmmessages`, `ec2messages` | Allows SSM to work in private subnet |

---

## EC2 Instance Configuration

- **Name:** `book-review-app-tier`
- **AMI:** Ubuntu Server 24.04 LTS
- **Instance Type:** t2.micro
- **Key Pair:** book-review-keypair
- **VPC:** `book-review-vpc`
- **Subnet:** `app-subnet-1` (Private — us-east-1a)
- **Auto-assign Public IP:** ❌ Disabled
- **Security Group:** `app-sg`
- **IAM Role:** `EC2-SSM-Role`

> The App Tier instance has no public IP address. It is only reachable from within the VPC through the Internal ALB.

---

## VPC Endpoints (Required for SSM in Private Subnet)

Since the App Tier has no internet access, three VPC Interface Endpoints were created to allow SSM Session Manager to function:

| Endpoint Name | Service | Purpose |
|---------------|---------|---------|
| `ssm-endpoint` | `com.amazonaws.us-east-1.ssm` | Core SSM service |
| `ssmmessages-endpoint` | `com.amazonaws.us-east-1.ssmmessages` | SSM session messaging |
| `ec2messages-endpoint` | `com.amazonaws.us-east-1.ec2messages` | EC2 message delivery |

All endpoints were placed in `app-subnet-1` and `app-subnet-2` with the `app-sg` security group attached.

---

## Software Installed

| Software | Version | Purpose |
|----------|---------|---------|
| Node.js | v18.x | JavaScript runtime |
| npm | 9.x | Package manager |
| Git | Latest | Clone repository |
| PM2 | Latest | Process manager |

---

## Deployment Steps

### 1. Connect via SSM Session Manager
```bash
# Connected via AWS Console → EC2 → Connect → Session Manager
whoami        # ubuntu
hostname -I   # 10.0.3.x (private IP confirmed)
```

### 2. Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 3. Install Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
```

### 4. Install Git and PM2
```bash
sudo apt install -y git
sudo npm install -g pm2
```

### 5. Clone Repository
```bash
cd /home/ubuntu
git clone https://github.com/vivianokose/book-review-app.git
cd book-review-app/backend
```

### 6. Install Dependencies
```bash
npm install
```

### 7. Configure Environment Variables
```bash
sudo nano .env
```

Contents of `.env`:
```env
PORT=3001
DB_HOST=<rds-primary-endpoint>
DB_USER=admin
DB_PASSWORD=<your-db-password>
DB_NAME=bookreviews
JWT_SECRET=<your-jwt-secret>
```

### 8. Start Backend with PM2
```bash
pm2 start src/server.js --name "backend"
pm2 startup
pm2 save
pm2 status
```

---

## Verification

```bash
# Confirm backend is running on port 3001
pm2 status
curl http://localhost:3001
```

---

## Architecture Diagram Reference

```
[Internal ALB]
      │
      ▼ (port 3001)
[book-review-app-tier EC2]
  └── app-subnet-1 (10.0.3.0/24)
  └── Private IP: 10.0.3.x
  └── Node.js/Express on port 3001
  └── Connected to RDS via db-sg → port 3306
```

---

## Why This Design?

- **Private subnet** — The backend is never directly accessible from the internet. All traffic must flow through the Internal ALB from the Web Tier.
- **SSM Session Manager** — Allows secure terminal access without SSH keys, bastion hosts, or open inbound ports.
- **VPC Endpoints** — Enable SSM to work in the private subnet without requiring internet access.
- **PM2** — Keeps the Node.js process running even if it crashes, and auto-restarts on server reboot.

---

## Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/14-app-ec2-instance.png` | App Tier EC2 details showing private IP and subnet |
| `screenshots/15-app-ssm-connected.png` | SSM terminal showing private IP via hostname -I |
| `screenshots/16-app-pm2-status.png` | PM2 showing backend process as online |
| `screenshots/17-vpc-endpoints.png` | Three VPC endpoints showing Available status |

---

## Troubleshooting

### SSM Session Manager Offline in Private Subnet
**Issue:** SSM ping status showed Offline despite IAM role being attached.
**Root Cause:** Private subnet has no internet access, so SSM agent could not reach AWS endpoints.
**Fix:** Created three VPC Interface Endpoints (ssm, ssmmessages, ec2messages) and added port 443 inbound to app-sg from within the VPC (10.0.0.0/16).

---

## Commit Reference

```
chore: deploy Node.js backend on app tier EC2 with PM2 and SSM access
```





## Troubleshooting: SSM Session Manager Offline

**Issues encountered:**
1. IAM instance profile was not attached at launch
2. Auto-assign Public IP was not enabled on first launch
3. Port 443 (HTTPS outbound) was not in the Security Group
4. Port 22 (SSH) was not in the Security Group inbound rules
5. Instance needed a reboot after IAM role was attached

**Fixes applied:**
1. Created IAM Role `EC2-SSM-Role` with `AmazonSSMManagedInstanceCore` policy
2. Terminated and relaunched instance with Auto-assign Public IP enabled
3. Added HTTPS port 443 outbound to Web SG
4. Added SSH port 22 inbound to Web SG
5. Rebooted instance — SSM agent re-registered successfully

**Lesson learned:** Always attach the IAM SSM role and enable Auto-assign
Public IP BEFORE launching your instance to avoid these issues.

### Missing start script in package.json
**Issue:** `npm start` failed with "Missing script: start"
**Root Cause:** The backend package.json had no start script defined
**Fix:** Added `"start": "node src/server.js"` to the scripts section in package.json

### Environment variable mismatch
**Issue:** Database connection failed silently
**Root Cause:** .env used `DB_PASSWORD` but db.js reads `DB_PASS`
**Fix:** Updated .env to use `DB_PASS` to match the variable name in db.js

### No internet access in private subnet
**Issue:** apt update and npm install failed with "Network is unreachable"
**Root Cause:** Private subnet has no internet access by default
**Fix:** Created a NAT Gateway in web-subnet-1 and added 0.0.0.0/0 → NAT Gateway
route to private-rt