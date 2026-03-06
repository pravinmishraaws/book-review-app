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


This is Deployed by **Venkatesh Gangavarapu** on Azure
