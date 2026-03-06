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

 
 Full Deployment Summary — Book Review App on AWS
I started by designing the network foundation, creating a custom VPC with a CIDR block of 10.0.0.0/16 and six subnets spread across two availability zones — two public subnets for the web tier and four private subnets split between the app and database tiers. I attached an Internet Gateway for public internet access and configured separate route tables for public and private subnets.
With the network in place, I created five security groups to control traffic between tiers, chaining them together so each tier only accepts traffic from the one directly in front of it — a pattern that ensures no layer is directly exposed to the internet except the public ALB.
Next I provisioned a MySQL 8.0 RDS instance in the private DB subnets with Multi-AZ enabled for high availability. I later returned to create a read replica in a separate availability zone after realising it was missed during the initial setup.
To access the private app EC2, I launched a bastion host in the public subnet, copied my PEM key to it, and used it as a jump box to SSH into the private instance. Once inside, I installed Node.js 20, cloned the Book Review application repository, configured the environment variables to point to the RDS endpoint, created the database manually via MySQL client, and started the backend with PM2 to keep it running persistently.
I then created the Internal ALB with a target group pointing to the app EC2 on port 5000, which gave the frontend a stable DNS endpoint to communicate with the backend. On the web EC2, I installed Node.js, Nginx, and PM2, built the Next.js frontend, configured the .env.local file with the Internal ALB DNS, and set up Nginx as a reverse proxy to forward port 80 traffic to the Next.js app running on port 3000. Finally I created a Public Internet-facing ALB with a target group pointing to the web EC2, and confirmed the app was fully accessible in the browser.
For the architecture diagram I used draw.io, manually placing AWS components tier by tier, connecting them with directional arrows, and colour-coding each tier for visual clarity.

What I Learned
I learned how to design and implement a proper three-tier architecture on AWS where each layer is isolated from the others through subnet placement and security group chaining. I understood the difference between a public and internal ALB and why the scheme cannot be changed after creation. I also learned that private EC2 instances need a NAT Gateway to access the internet for package installation, even though they themselves remain unreachable from outside. Working through the environment variable names in the source code taught me the importance of inspecting the actual application code rather than assuming variable names. I also understood the difference between Multi-AZ (high availability through automatic failover) and a Read Replica (scalability through read offloading).
Issues Faced
The first major issue was that sudo apt update failed on the private EC2 with a network unreachable error — this was caused by a missing NAT Gateway route in the private route table, which I fixed by creating a NAT Gateway in the public subnet and adding a 0.0.0.0/0 route pointing to it.
The backend failed to start initially because the database bookreviews did not exist on RDS — it had to be created manually by connecting to RDS via the MySQL client and running CREATE DATABASE bookreviews.
The Public ALB was accidentally created as Internal instead of Internet-facing — since the scheme cannot be edited after creation, I had to delete it and recreate it correctly.
The app EC2 security group initially had SSH open to 0.0.0.0/0 which is a security risk — I removed that rule and restricted SSH access to the bastion security group only.
PM2 had to be installed separately on the web EC2 since it was only installed on the app EC2 earlier, and the read replica had to be created in a second pass after being missed during the initial RDS setup.
