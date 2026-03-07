# 03 — RDS MySQL Setup

## Overview

This document covers the database tier configuration for the Book Review App AWS deployment. Amazon RDS for MySQL was configured with Multi-AZ for high availability and a Read Replica for read scalability. The database is placed in private subnets and is only accessible from the App Tier. A managed MySQL database was created using Amazon RDS inside the private DB subnets of `book-review-vpc`. A Read Replica was also provisioned in a second Availability Zone to support read scalability and demonstrate high availability best practices.

---

## Resources Created

| Resource | Name | Role |
|----------|------|------|
| DB Subnet Group | `book-review-db-subnet-group` | Defines which subnets RDS can use |
| Primary RDS Instance | `book-review-db` | Handles all read/write operations |
| Read Replica | `book-review-db-replica` | Handles read traffic, separate AZ |

---

## DB Subnet Group

- **Name:** `book-review-db-subnet-group`
- **VPC:** `book-review-vpc`
- **Subnets included:**

| Subnet | Availability Zone | CIDR |
|--------|-------------------|------|
| `db-subnet-1` | us-east-1a | 10.0.5.0/24 |
| `db-subnet-2` | us-east-1b | 10.0.6.0/24 |

> A DB subnet group tells RDS which subnets are eligible for database placement. Both subnets are private — no internet routing.

---

## Primary RDS Instance — `book-review-db`

| Setting | Value |
|---------|-------|
| Engine | MySQL 8.0 |
| Template | Free Tier / Dev & Test
| Instance Class | db.t3.micro |
| Storage | 20 GB (gp2) |
| Storage Autoscaling | Disabled |
| Master Username | `admin` |
| Initial Database Name | `bookreviews` |
| VPC | `book-review-vpc` |
| Subnet Group | `book-review-db-subnet-group` |
| Availability Zone | us-east-1a |
| Security Group | `db-sg` |
| Public Access | ❌ No |
| Authentication | Password authentication |
| Port | 3306

> Multi-AZ creates a standby replica in a different AZ. If the primary fails, RDS automatically fails over to the standby — no manual intervention required.

---

### Endpoint

```
book-review-db.xxxxxxxxxx.us-east-1.rds.amazonaws.com
```

*(Replace with your actual endpoint from the RDS console)*

---

## Read Replica — `book-review-db-replica`

| Setting | Value |
|---------|-------|
| Source Instance | `book-review-db` |
| Instance Class | db.t3.micro |
| VPC | `book-review-vpc` |
| Subnet Group | `book-review-db-subnet-group` |
| Availability Zone | us-east-1b |
| Security Group | `db-sg` |
| Public Access | ❌ No |

> The read replica is placed in `us-east-1b` — a different AZ from the primary — ensuring that a failure in one zone does not affect both database instances.

---

> The Read Replica offloads read queries from the primary instance, improving performance for read-heavy workloads like fetching book lists and reviews.

---

## Connection Details

| Detail | Value |
|--------|-------|
| Primary Endpoint | book-review-db.cgdwgcgy8hsp.us-east-1.rds.amazonaws.com |
| Replica Endpoint | book-review-db-replica.cgdwgcgy8hsp.us-east-1.rds.amazonaws.com |
| Port | 3306 |
| Database Name | `bookreviews` |
| Username | `admin` |
| Engine Version | MySQL 8.4.8 |
| Instance Class | db.t3.micro |
| Multi-AZ | No (Free Tier limitation) |
| Read Replica | book-review-db-replica |

---

## Architecture Diagram Reference

```
                    [App Tier EC2]
                          │
                          ▼ (port 3306)
                    ┌─────────────┐
                    │  Primary DB  │  ← book-review-db (us-east-1a)
                    │  (Multi-AZ)  │
                    └──────┬──────┘
                           │ automatic failover
                    ┌──────▼──────┐
                    │  Standby DB  │  ← us-east-1b (managed by AWS)
                    └─────────────┘

                    ┌─────────────┐
                    │ Read Replica │  ← book-review-db-replica
                    └─────────────┘
```

---

- The RDS instances are in **private subnets only** — no route to the internet exists
- Only resources attached to `app-sg` can reach the database on port 3306
- The database is never directly accessible from a browser, SSH session, or public IP

---

## Database Details

| Property | Value |
|----------|-------|
| Database Name | `bookreview` |
| Port | `3306` |
| Username | `admin` |
| Password | *(stored securely — never committed to Git)* |

> ⚠️ Never hardcode your RDS password in your source code or commit it to GitHub. Always use environment variables (`.env` files) and add `.env` to your `.gitignore`.

---

## Why This Design?
- **Multi-AZ** — Provides automatic failover if the primary DB instance fails. The standby is in a different AZ and is promoted automatically by AWS.
- **Private subnets** — The database has no public IP and no internet route. It is only reachable from within the VPC by the app tier security group at port 3306.
- **Read Replica in separate AZ** — Offloads read queries from the primary and provides a warm standby in case the primary AZ experiences issues.
- **Security group chaining** — `db-sg` only allows port 3306 from `app-sg`. Even if someone gains access to the VPC, they cannot reach the DB without also having the app-tier security group attached.
- **Named initial database** — Setting `bookreview` as the initial DB name during creation ensures the Sequelize ORM can connect and sync models immediately without manual DB creation.
- **No public access** — Ensures the database is fully isolated from external threats.

---

## Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/10-rds-instance-created.png` | RDS primary instance showing Available status |
| `screenshots/11-rds-multi-az.png` | RDS configuration showing Multi-AZ enabled |
| `screenshots/12-rds-read-replica.png` | Read Replica instance showing Available status |
| `screenshots/13-rds-subnet-group.png` | DB Subnet Group spanning both AZs |

---

## Troubleshooting

*(To be updated if any issues are encountered)*

---

## Commit Reference

```
chore: add RDS MySQL with Multi-AZ and read replica for database tier
```