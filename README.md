# 🚚 Delivery System

A production-like delivery platform built to simulate a real-world software project using **Laravel**, **React**, and **Flutter**.

This project is designed to understand how modern software systems are built and how backend, dashboard, and mobile applications work together in a professional development environment.

---

# 🎯 Project Goal

This project is **not** intended to become a complete production delivery platform.

The goal is to:

- Understand real software architecture.
- Learn how Laravel, React, and Flutter integrate.
- Build and consume REST APIs.
- Simulate a professional development workflow.
- Prepare for working on a real delivery company project.

The focus is on learning the workflow and architecture rather than implementing every possible feature.

---

# 🏗️ Tech Stack

## Backend

- Laravel 12
- PHP 8+
- MySQL
- Laravel Sanctum

## Dashboard

- React
- Vite
- TypeScript
- Axios
- React Query

## Mobile

- Flutter
- Dart
- Bloc / Cubit
- Dio

---

# 📁 Repository Structure

```
delivery-system/

├── backend/          # Laravel REST API
├── dashboard/        # React Admin Dashboard
├── mobile/           # Flutter Customer App
│
├── README.md
├── AGENTS.md
├── PROJECT.md
└── TASKS.md
```

---

# 📦 Applications

## Backend (Laravel)

Responsible for:

- Authentication
- Authorization
- Business Logic
- Validation
- Database
- REST API

The backend is the single source of truth.

---

## Dashboard (React)

Responsible for:

- Restaurant Management
- Category Management
- Product Management
- Order Management
- User Management
- Dashboard Statistics

The dashboard communicates only with the Laravel API.

---

## Mobile (Flutter)

Responsible for:

- Customer Authentication
- Restaurant Browsing
- Product Browsing
- Shopping Cart
- Orders
- Profile Management

The mobile app communicates only with the Laravel API.

---

# 🔄 System Architecture

```
             Flutter Mobile
                    │
                    │
                    ▼
            Laravel REST API
                    ▲
                    │
                    │
          React Dashboard
                    │
                    ▼
                 MySQL
```

Neither Flutter nor React communicates directly with the database.

All business logic lives inside Laravel.

---

# 📚 Documentation

| File | Purpose |
|------|---------|
| **AGENTS.md** | Rules and guidelines for AI agents and developers |
| **PROJECT.md** | Complete project documentation (features, business rules, architecture, entities, workflow) |
| **TASKS.md** | Development roadmap and progress tracking |

---

# 🚀 Development Workflow

The project will be developed in the following order:

1. Planning
2. Laravel Backend
3. React Dashboard
4. Flutter Mobile
5. Testing
6. Improvements

---

# 💡 Development Principles

- Keep the code simple.
- Follow the existing architecture.
- Backend owns all business logic.
- Flutter and React consume the API only.
- Reuse existing code whenever possible.
- Avoid duplicate logic.
- Write readable and maintainable code.

---

# 🤖 Working with AI

Before generating code, every AI agent should:

1. Read `README.md`
2. Read `PROJECT_GUIDE.md`
3. Read `AGENTS.md`
4. Review the existing codebase
5. Explain the implementation plan
6. Implement the smallest possible change

AI should assist development, not replace engineering decisions.

---

# 📈 Current Status

Current Phase:

> Project Planning & Setup

The next milestone is building the Laravel backend.

---

# 📄 License

This project is built for educational purposes and to simulate a professional software development workflow.

---

Built with ❤️ using Laravel, React, Flutter, and AI-assisted development.