# AGENTS.md

# AI Development Guide

This project is built to simulate a real-world software development workflow using Laravel, React, and Flutter.

Your role is to assist in development while preserving the project's architecture, consistency, and code quality.

---

# Project Goal

The purpose of this project is to understand how a real delivery platform is built.

This is a learning project, but it should be developed using production-level practices.

Prioritize understanding and maintainability over speed.

---

# Before Writing Code

Always follow these steps:

1. Read `README.md`
2. Read `PROJECT.md`
3. Read `ARCHITECTURE.md`
4. Understand the existing code.
5. Explain your implementation plan.
6. Implement the smallest possible change.

Never start coding immediately.

---

# General Rules

- Follow the existing architecture.
- Reuse existing code whenever possible.
- Keep implementations simple.
- Write readable code.
- Prefer consistency over personal preference.
- Avoid unnecessary abstractions.
- Keep functions and classes focused.

---

# Never

- Never duplicate business logic.
- Never rewrite working code without a reason.
- Never hardcode values.
- Never break the existing architecture.
- Never introduce new libraries without approval.
- Never move business logic into the UI.
- Never guess requirements.
- Never change unrelated files.

---

# Always

- Explain your approach before coding.
- Keep changes small and incremental.
- Use meaningful names.
- Handle errors properly.
- Keep the project organized.
- Update documentation when needed.

---

# Backend Rules (Laravel)

- Use RESTful APIs.
- Keep Controllers thin.
- Put business logic inside Services.
- Use Form Requests for validation.
- Use Eloquent relationships correctly.
- Return consistent JSON responses.
- Never expose internal errors.

---

# Dashboard Rules (React)

- Organize code by feature.
- Separate UI from API logic.
- Use reusable components.
- Use Axios for API requests.
- Use React Query for server state.
- Avoid unnecessary global state.

---

# Mobile Rules (Flutter)

- Follow Clean Architecture.
- Use Cubit for state management.
- Use Dio for networking.
- Keep Widgets focused on UI.
- Never call APIs directly from Widgets.
- Separate Presentation, Domain, and Data layers.

---

# Code Style

- Classes → PascalCase
- Methods → camelCase
- Variables → camelCase
- Constants → UPPER_SNAKE_CASE
- Database tables → snake_case
- Routes → kebab-case

Use descriptive names.

Avoid abbreviations unless they are widely understood.

---

# Error Handling

Every feature should handle:

- Loading
- Success
- Empty State
- Validation Errors
- Unauthorized
- Server Errors

Never ignore exceptions.

---

# Workflow

When implementing a feature:

1. Understand the requirement.
2. Review the existing code.
3. Identify affected files.
4. Explain the implementation plan.
5. Write the code.
6. Verify the result.
7. Suggest improvements if appropriate.

---

# If You're Unsure

Do not guess.

Ask for clarification before implementing.

---

# Success Criteria

A task is considered complete when:

- The feature works correctly.
- Existing functionality is not broken.
- The code follows the project architecture.
- No unnecessary complexity was introduced.
- The implementation is easy to understand.

---

The goal is not to generate more code.

The goal is to generate better code.