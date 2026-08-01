# COMMANDS.md — How to Run the Project

A step-by-step guide to run the full Delivery System project locally.

---

## Prerequisites

Make sure these are installed on your machine:

- **PHP** >= 8.2
- **Composer**
- **Node.js** >= 18
- **npm**

---

## First-Time Setup (Run Once)

### 1. Backend (Laravel)

```bash
cd /Users/aboody/Desktop/Delivery-System/backend

# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Run database migrations
php artisan migrate

# Seed the admin user
php artisan db:seed --class=AdminSeeder
```

### 2. Dashboard (React)

```bash
cd /Users/aboody/Desktop/Delivery-System/dashboard

# Install Node.js dependencies
npm install react-router-dom axios @tanstack/react-query
```

---

## Running the Project (Every Time)

Open **two separate Terminal windows**.

### Terminal 1 — Backend API Server

```bash
cd /Users/aboody/Desktop/Delivery-System/backend
php artisan serve
```

Server will run on: **http://127.0.0.1:8000**

---

### Terminal 2 — React Dashboard

```bash
cd /Users/aboody/Desktop/Delivery-System/dashboard
npm run dev
```

Dashboard will run on: **http://localhost:5173**

---

## Login Credentials

| Field    | Value             |
|----------|-------------------|
| Email    | admin@admin.com   |
| Password | password          |
| Role     | admin             |

---

## Running Tests

```bash
cd /Users/aboody/Desktop/Delivery-System/backend
php artisan test
```

---

## Stop All Servers

Press **Ctrl + C** in each Terminal window.

---

## Project URLs Summary

| Service          | URL                       |
|------------------|---------------------------|
| Backend API      | http://127.0.0.1:8000     |
| API Base URL     | http://127.0.0.1:8000/api/v1 |
| React Dashboard  | http://localhost:5173     |


server php:
php artisan serve

react dashboard:
npm run dev

image serve:
php artisan storage:link
