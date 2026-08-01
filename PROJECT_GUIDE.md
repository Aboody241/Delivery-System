# PROJECT.md

# Delivery System

Project Documentation

Version: 1.0

---

# Overview

Delivery System is a learning project designed to simulate the architecture of a real-world food delivery platform.

The project consists of three applications sharing one backend:

- Laravel Backend API
- React Admin Dashboard
- Flutter Mobile Application

The objective is to understand how these applications work together in a professional environment.

---

# Project Goals

This project aims to:

- Understand real software architecture.
- Learn Laravel, React, and Flutter integration.
- Practice building RESTful APIs.
- Simulate a production workflow.
- Prepare for working on a real delivery company project.

---

# Technology Stack

## Backend

- Laravel
- PHP
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

# User Roles

## Customer

Can:

- Register
- Login
- Browse restaurants
- Browse products
- Search products
- Manage cart
- Place orders
- View order history
- Update profile

---

## Administrator

Can:

- Login
- Manage restaurants
- Manage categories
- Manage products
- Manage users
- Manage orders
- View statistics

---

## Future Roles

- Restaurant Owner
- Driver

These roles are outside the MVP scope.

---

# MVP Features

Authentication

Restaurant Management

Category Management

Product Management

Shopping Cart

Order Management

Order History

Profile Management

Dashboard Statistics

REST API

---

# Future Features

- Driver Application
- Restaurant Portal
- Online Payments
- Coupons
- Push Notifications
- Reviews
- Ratings
- Loyalty Program
- Multi-language Support

---

# Business Rules

## Restaurants

- A restaurant can have many categories.
- A restaurant can have many products.
- Inactive restaurants cannot receive new orders.

---

## Categories

- Each category belongs to one restaurant.
- A category can contain many products.

---

## Products

- Each product belongs to one restaurant.
- Each product belongs to one category.
- Product price must be greater than zero.
- Products may be unavailable without being deleted.

---

## Cart

- A customer has one active cart.
- A cart contains products from one restaurant only.
- Quantity must always be greater than zero.

---

## Orders

- Orders cannot be edited after checkout.
- Prices are stored at checkout.
- Historical orders never change.

Order Status:

Pending

↓

Accepted

↓

Preparing

↓

Ready

↓

Out For Delivery

↓

Delivered

Cancelled orders cannot continue.

Delivered orders cannot be modified.

---

# Core Entities

The project contains the following entities:

- User
- Restaurant
- Category
- Product
- Cart
- Cart Item
- Order
- Order Item

Future:

- Driver
- Payment
- Coupon
- Review

---

# Database Overview

Main Tables

- users
- restaurants
- categories
- products
- carts
- cart_items
- orders
- order_items

---

# API Overview

Backend exposes a RESTful API.

React Dashboard and Flutter Mobile communicate only through this API.

The Backend is the single source of truth.

Business logic never exists in Flutter or React.

---

# Development Workflow

The project will be built in the following order:

1. Laravel Backend
2. React Dashboard
3. Flutter Mobile
4. Testing
5. Improvements

---

# Project Principles

- Keep the architecture simple.
- Reuse code whenever possible.
- Follow REST principles.
- Keep Controllers thin.
- Business logic belongs in the Backend.
- Keep UI separated from business logic.
- Write maintainable code.

---

# Current Progress

## Documentation

- [x] README
- [x] AGENTS
- [x] PROJECT

## Backend

- [ ] Authentication
- [ ] Restaurants
- [ ] Categories
- [ ] Products
- [ ] Orders

## Dashboard

- [ ] Setup
- [ ] Authentication
- [ ] Products
- [ ] Orders

## Mobile

- [ ] Setup
- [ ] Authentication
- [ ] Home
- [ ] Cart
- [ ] Orders

---

# Notes

This project focuses on learning real-world architecture rather than implementing every possible delivery feature.

The priority is understanding how backend, dashboard, and mobile applications interact in a professional software project.