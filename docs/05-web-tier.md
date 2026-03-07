# 05 — Web Tier Deployment

## Overview

This document covers the deployment of the Next.js frontend on the Web Tier EC2 instance. The instance runs in a public subnet, sits behind the Public Application Load Balancer, and uses Nginx as a reverse proxy to forward traffic to the Next.js app on port 3000.

---

## Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| EC2 Instance | `book-review-web-tier` | Runs Next.js frontend behind Nginx |
| IAM Role | `EC2-SSM-Role` | Enables SSM Session Manager access |

---

## EC2 Instance Configuration

- **Name:** `book-review-web-tier`
- **AMI:** Ubuntu Server 24.04 LTS
- **Instance Type:** t2.micro
- **Key Pair:** book-review-keypair
- **VPC:** `book-review-vpc`
- **Subnet:** `web-subnet-1` (Public — us-east-1a)
- **Auto-assign Public IP:** ✅ Enabled
- **Security Group:** `web-sg`
- **IAM Role:** `EC2-SSM-Role`

---

## Software Installed

| Software | Version | Purpose |
|----------|---------|---------|
| Node.js | v18.x | JavaScript runtime for Next.js |
| npm | 9.x | Package manager |
| Nginx | Latest | Reverse proxy on port 80 |
| Git | Latest | Clone repository |
| PM2 | Latest | Process manager |

---

## Deployment Steps

### 1. Connect via SSM Session Manager
```bash
# Connected via AWS Console → EC2 → Connect → Session Manager
whoami        # ubuntu
hostname -I   # 10.0.1.x + public IP
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

### 4. Install Nginx and Git
```bash
sudo apt install -y nginx git
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

### 5. Install PM2
```bash
sudo npm install -g pm2
```

### 6. Clone Repository
```bash
cd /home/ubuntu
git clone https://github.com/vivianokose/book-review-app.git
cd book-review-app/frontend
```

### 7. Configure Environment Variables
```bash
sudo nano .env.local
```

Contents of `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://<internal-alb-dns>
```

> Replace `<internal-alb-dns>` with the Internal ALB DNS name once it is created in Phase 6.

### 8. Install Dependencies and Build
```bash
npm install
npm run build
```

### 9. Start Frontend with PM2
```bash
pm2 start npm --name "frontend" -- start
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save
pm2 status
```

### 10. Configure Nginx as Reverse Proxy
```bash
sudo rm /etc/nginx/sites-enabled/default
sudo nano /etc/nginx/sites-available/book-review
```

Contents of Nginx config:
```nginx
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/book-review /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl status nginx
```

---

## Verification

```bash
# Confirm Next.js is running on port 3000
pm2 status

# Confirm Nginx is active
sudo systemctl status nginx

# Test locally
curl http://localhost
```

App accessible at: `http://<public-ip>` ✅

---

## Architecture Diagram Reference

```
INTERNET
    │
    ▼ (port 80)
[Public ALB]
    │
    ▼ (port 80)
[book-review-web-tier EC2]
  └── web-subnet-1 (10.0.1.0/24)
  └── Nginx → port 80 → proxies to → Next.js port 3000
  └── PM2 keeps Next.js running
  └── Communicates with App Tier via Internal ALB
```

---

## Why This Design?

- **Nginx as reverse proxy** — Nginx handles incoming HTTP traffic on port 80 and forwards it to the Next.js process on port 3000. This is standard production practice.
- **PM2 process manager** — Keeps the Node.js/Next.js process alive if it crashes and auto-restarts on EC2 reboot.
- **Public subnet** — The Web Tier needs to be reachable from the internet via the Public ALB.
- **Auto-assign public IP** — Enabled on the subnet so EC2 instances get a public IP automatically at launch.

---

## Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/18-web-ec2-instance.png` | Web Tier EC2 details showing public IP and subnet |
| `screenshots/19-nginx-status.png` | Nginx showing active (running) status |
| `screenshots/20-pm2-status.png` | PM2 showing frontend process as online |
| `screenshots/21-app-ui-browser.png` | Book Review App loading in browser via public IP |

---

## Troubleshooting

### SSM Session Manager Offline
**Issue:** SSM ping status showed Offline on first launch attempt.
**Root Cause 1:** IAM instance profile was not attached at launch.
**Root Cause 2:** Auto-assign Public IP was not enabled — instance had no public IP to reach SSM endpoints.
**Root Cause 3:** Port 443 outbound and port 22 inbound were missing from web-sg.
**Fix:** Terminated instance, relaunched with Auto-assign Public IP enabled, attached IAM role at launch, added missing security group rules, rebooted instance.

### npm run build — ENOENT Error
**Issue:** `npm run build` failed with `ENOENT: no such file or directory, open '/home/ubuntu/package.json'`
**Root Cause:** Command was run from `/home/ubuntu` instead of `/home/ubuntu/book-review-app/frontend`
**Fix:** Navigated to the correct directory before running the build command.

---

## Commit Reference

```
chore: deploy Next.js frontend on web tier EC2 with Nginx and PM2
```