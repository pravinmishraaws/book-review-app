# Book Review App

## Overview

**Book Review App** is a modern, full-stack **three-tier web application** that allows users to browse books, read reviews, and submit their own. It demonstrates clean separation of concerns between frontend and backend, and is ideal for hands-on DevOps and cloud deployment practices.

- **Unauthenticated users** can view book details and existing reviews.
- **Authenticated users** can register, log in, and submit reviews.

This project is part of the **[DevOps Zero to Hero: Docker, K8s, Cloud, CI/CD & 4 Projects](https://www.udemy.com/user/pravin-mishra-30/)** Udemy course and designed to help students practice DevOps tools and cloud infrastructure end-to-end.

---

## Architecture

- **Frontend**: Built using **Next.js**, providing server-side rendering and dynamic routing.
- **Backend**: Powered by **Node.js** and **Express.js**, handling authentication, book data, and reviews.
- **Database**: Uses **MySQL** with Sequelize ORM.
  
This three-tier architecture can be independently deployed, making it ideal for containerization, cloud hosting, and CI/CD implementation.

![Two-tiered-Web-application-architecture](https://github.com/user-attachments/assets/0be7ab58-91d0-4cde-9272-1c74ca783b4c)


---

## Features

### 🔐 User Authentication
- User registration and login
- Email and password-based login
- Secure authentication using JWT tokens

### 📚 Book Management
- View all books
- Fetch detailed info for each book
- (Future enhancement: Admins can add/edit books)

### 📝 Review System
- View reviews for each book
- Authenticated users can post reviews
- Each review includes rating, username, and timestamp

### 🔄 State Management & API Integration
- Frontend dynamically interacts with backend APIs
- React Context manages global authentication state

---

## Technology Stack

### Frontend
- [Next.js](https://nextjs.org/) – React framework for SSR and routing  
- Tailwind CSS – Utility-first CSS framework  
- Axios – HTTP client for API calls  
- React Context API – For managing global auth state  

### Backend
- Node.js & Express.js – REST API development  
- MySQL & Sequelize – Relational DB and ORM  
- JWT – Token-based authentication  
- bcrypt.js – Password hashing  
- CORS – Cross-origin request handling  

---

## Application Structure

```
/book-review-app
 ├── /frontend   # Next.js frontend
 ├── /backend    # Node.js & Express backend
 └── README.md   # Project overview
```

---

## Frontend Directory Layout

```
/frontend
 ├── /src
 │   ├── /app
 │   │   ├── page.js          # Home page (list of books)
 │   │   ├── /book/[id]       # Dynamic route for book details
 │   │   ├── /login           # Login page
 │   │   ├── /register        # Register page
 │   ├── /components          # Reusable UI components (Navbar, etc.)
 │   ├── /context             # React Context for auth state
 │   ├── /services            # Axios API functions
 │   ├── /styles              # Tailwind global styles
 ├── next.config.js           # Next.js config
 ├── package.json             # Dependencies and scripts
 └── README.md                # Frontend-specific docs
```

---

## Backend Directory Layout

```
/backend
 ├── /src
 │   ├── /config              # Database config and connection
 │   ├── /models              # Sequelize models (User, Book, Review)
 │   ├── /routes              # Express route handlers
 │   ├── /controllers         # API business logic
 │   ├── /middleware          # JWT auth middleware
 │   └── server.js            # Entry point of the backend server
 ├── package.json             # Dependencies and scripts
 └── README.md                # Backend-specific docs
```

---

## Setup Instructions

Setup steps for both frontend and backend are provided in their respective folders:

- [`/frontend/README.md`](./frontend/README.md)
- [`/backend/README.md`](./backend/README.md)

Follow the instructions to install dependencies, configure environment variables, and start the application locally.

---

## About This Project

This project is designed exclusively for the **Udemy course: [DevOps Zero to Hero: Docker, K8s, Cloud, CI/CD & 4 Projects]([https://www.udemy.com](https://www.udemy.com/user/pravin-mishra-30/))**.

Students will gain hands-on experience in:
- Git, Docker, Kubernetes
- Terraform, Ansible
- CI/CD Pipelines
- AWS & Azure Cloud
- Full-stack project deployment from scratch

This Book Review App serves as one of the **4 real-world DevOps projects** taught in the course.

#### Testing CICD Pipeline



JOY UKPABI: DMI COhort one


# 📚 Book Review App — AWS Three-Tier Architecture Deployment

A production-grade, fully deployed three-tier web application on AWS using Next.js, Node.js/Express, and MySQL RDS. This repository documents the complete infrastructure deployment across networking, compute, and database layers following real-world cloud engineering best practices.

---

## 🏗️ Architecture Overview

```
Internet
    │
    ▼
Public ALB (Internet-facing)
    │
    ▼
Web EC2 — Next.js + Nginx (Public Subnet)
    │
    ▼
Internal ALB (Internal)
    │
    ▼
App EC2 — Node.js / Express (Private Subnet)
    │
    ▼
RDS MySQL — Multi-AZ + Read Replica (Private Subnet)
```

---

## 🌐 AWS Region

**US East (Ohio) — us-east-2**

---

## ⚙️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 14, Nginx |
| Backend | Node.js 20, Express.js |
| Database | MySQL 8.0 (Amazon RDS) |
| Process Manager | PM2 |
| Web Server | Nginx (Reverse Proxy) |
| Infrastructure | AWS (VPC, EC2, RDS, ALB) |

---

## ☁️ AWS Services Used

| Service | Purpose |
|---------|---------|
| Amazon VPC | Custom network isolation (10.0.0.0/16) |
| Subnets (x6) | Tier separation across 2 Availability Zones |
| Internet Gateway | Public internet access for web tier |
| NAT Gateway | Outbound internet for private instances |
| Route Tables | Traffic routing between tiers |
| Security Groups | Firewall rules between tiers |
| Amazon EC2 | Web server, App server, Bastion host |
| Application Load Balancer | Public ALB (web) + Internal ALB (app) |
| Amazon RDS MySQL 8.0 | Managed database with Multi-AZ failover |
| RDS Read Replica | Read scalability |

---

## 🗂️ Repository Structure

```
book-review-app/
├── frontend/                  # Next.js frontend
│   ├── src/
│   │   ├── app/
│   │   ├── components/
│   │   ├── context/
│   │   └── services/
│   ├── .env.local             # Environment variables (not committed)
│   └── package.json
├── backend/                   # Node.js/Express backend
│   ├── src/
│   │   ├── config/
│   │   │   └── db.js          # Sequelize DB connection
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── routes/
│   │   └── server.js          # Entry point, runs on PORT 5000

│   ├── .env                   # Environment variables (not committed)
│   └── package.json
├── docker-compose.yml
└── README.md
```

---

## 🔐 Network Architecture

### VPC & Subnets

| Subnet | CIDR | Type | AZ |
|--------|------|------|----|
| web-subnet-1 | 10.0.1.0/24 | Public | us-east-2a |
| app-subnet-1 | 10.0.3.0/24 | Private | us-east-2a |
| app-subnet-2 | 10.0.4.0/24 | Private | us-east-2b |
| db-subnet-1 | 10.0.5.0/24 | Private | us-east-2a |
| db-subnet-2 | 10.0.6.0/24 | Private | us-east-2b |

### Security Group Chain

```
public-alb-sg (port 80 open to internet)
    └── web-ec2-sg (port 80 from public-alb-sg only)
            └── internal-alb-sg (port 3001 from web-ec2-sg only)
                    └── app-ec2-sg (port 5000 from internal-alb-sg only)
                            └── db-sg (port 3306 from app-ec2-sg only)
```

---

## 🚀 Deployment Guide

### Prerequisites
- AWS Account with appropriate permissions
- Key pair (.pem file) for EC2 access
- AWS CLI configured (optional)

---

### Step 1 — VPC & Networking

```bash
# Create VPC with CIDR 10.0.0.0/16
# Create 6 subnets across 2 AZs
# Attach Internet Gateway
# Create NAT Gateway in public subnet
# Configure public and private route tables
```

- Public route table: `0.0.0.0/0` → Internet Gateway
- Private route table: `0.0.0.0/0` → NAT Gateway

---

### Step 2 — Security Groups

Create 5 security groups chained as shown above. Never open the database or app tier directly to the internet.

---

### Step 3 — RDS MySQL

```bash
# Create DB subnet group using db-subnet-1 and db-subnet-2
# Launch RDS MySQL 8.0 with Multi-AZ enabled
# No public access
# Security group: db-sg
# Initial database name: bookreviews
```

> ⚠️ If the initial database name is not set during provisioning, connect via MySQL client and create it manually:

```sql
CREATE DATABASE bookreviews;
```

---

### Step 4 — App Tier EC2 (Backend)

```bash
# SSH via bastion host
ssh -i "your-key.pem" ubuntu@<bastion-public-ip>
ssh -i ~/.ssh/your-key.pem ubuntu@<app-ec2-private-ip>

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2
sudo npm install -g pm2

# Clone and configure
git clone https://github.com/<your-repo>/book-review-app.git
cd book-review-app/backend
```

Create `.env` file:

```env
DB_HOST=<your-rds-endpoint>
DB_NAME=bookreviews
DB_USER=admin
DB_PASS=<your-password>
DB_PORT=3306
PORT=5000
JWT_SECRET=<your-secret>
```

```bash
# Install dependencies and start
npm install
pm2 start src/server.js --name "book-review-backend"
pm2 save
pm2 startup
```

---

### Step 5 — Internal ALB

- Create target group `app-tier-tg` on port **5000**
- Create Internal ALB pointing to `app-subnet-1` and `app-subnet-2`
- Listener: HTTP port 80 → forward to `app-tier-tg`
- Confirm target shows **Healthy**

---

### Step 6 — Web Tier EC2 (Frontend)

```bash
# SSH directly (public subnet)
ssh -i "your-key.pem" ubuntu@<web-ec2-public-ip>

# Install dependencies
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs nginx
sudo npm install -g pm2
```

Create `.env.local` in the frontend folder:

```env
NEXT_PUBLIC_API_URL=http://<internal-alb-dns>
```

```bash
# Build and start
npm install
npm run build
pm2 start npm --name "book-review-frontend" -- start
pm2 save
pm2 startup
```

Configure Nginx reverse proxy:

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
sudo nginx -t
sudo systemctl restart nginx
```

---

### Step 7 — Public ALB

- Create target group `web-tier-tg` on port **80**
- Create Internet-facing ALB pointing to `web-subnet-1` and `web-subnet-2`
- Security group: `public-alb-sg`
- Listener: HTTP port 80 → forward to `web-tier-tg`
- Confirm target shows **Healthy**

---

## 🔒 Environment Variables

### Backend `.env`

```env
DB_HOST=<rds-endpoint>
DB_NAME=bookreviews
DB_USER=admin
DB_PASS=<password>
DB_PORT=3306
PORT=5000
JWT_SECRET=<secret-key>
ALLOWED_ORIGINS=http://<public-alb-dns>
```

### Frontend `.env.local`

```env
NEXT_PUBLIC_API_URL=http://<internal-alb-dns>
```

> ⚠️ Never commit `.env` or `.env.local` files to version control. Add them to `.gitignore`.

---

## 🧪 Verification

Once deployed, verify the full stack:

```bash
# On App EC2 — confirm backend is running
pm2 status
curl http://localhost:5000
# Expected: 📚 Book Review API is running...

# Confirm DB connection
mysql -h <rds-endpoint> -u admin -p'<password>' bookreviews
SHOW TABLES;
``

---

## ⚠️ Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| `apt update` fails on private EC2 | Add NAT Gateway route to private route table |
| `Unknown database` error | Connect via MySQL client and run `CREATE DATABASE bookreviews` |
| Target group shows Unhealthy | Check app is running on correct port via `pm2 status` |
| Public ALB returns 503 | At least one target must be Healthy before traffic routes |
| Public ALB created as Internal | Delete and recreate — scheme cannot be changed after creation |
| Frontend API calls failing | Check `NEXT_PUBLIC_API_URL` in `.env.local` matches internal ALB DNS |
| SSH to private EC2 fails | Use bastion host — private instances have no direct SSH access |

---

## 🏆 Key Learnings

- Security groups chained as sources (not IP ranges) is the production-grade approach
- Private instances need NAT Gateway for outbound internet — they remain unreachable inbound
- Multi-AZ RDS provides automatic failover — the endpoint DNS stays the same after failover
- `NEXT_PUBLIC_` prefix is required for Next.js environment variables accessible in the browser
- PM2 `startup` command registers the process manager as a system service for auto-restart on reboot
- ALB scheme (internal vs internet-facing) cannot be changed after creation

---

## 👩‍💻 Author

Deployed by **Joy Ukpabi** as part of an AWS Cloud Engineering capstone project.

---

## 📄 License

This project is for educational purposes as part of an AWS Cloud Engineering course.| web-subnet-2 | 10.0.2.0/24 | Public | us-east-2b |

