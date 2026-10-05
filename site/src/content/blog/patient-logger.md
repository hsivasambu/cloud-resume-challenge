---
title: "Patient Logger: Multi-Tenant Clinical Task Tracking"
description: "A full-stack clinical task tracker with role-based access, PostgreSQL tenant isolation, and a containerized development stack."
date: 2025-07-22
tags: ["healthcare", "web design", "reflection"]
draft: false
---

## Project at a glance

- **Problem:** Patient-related tasks can be fragmented across systems, making ownership and activity difficult to review.
- **My role:** Built a personal full-stack project inspired by the healthcare workflows I encounter as a project manager.
- **Key tradeoff:** Focused on patients, users, and task logs; deferred external integrations and real-time feeds.
- **Delivered:** A React interface, Node.js REST API, role-based access, PostgreSQL Row Level Security, and a Docker-based stack.
- **Validation focus:** Authentication, ownership, and tenant boundaries. Jest and Supertest support API testing; deeper boundary coverage remains a next step.
- **Status and limitations:** A sandbox project, not a deployed clinical platform. No clinical effectiveness or compliance validation is claimed.

[Backend repository](https://github.com/hsivasambu/patient-task-logger-backend) · [Frontend repository](https://github.com/hsivasambu/patient-task-logger-frontend)

I built Patient Logger to explore how clinical task tracking changes when user roles, data ownership, and organization boundaries are explicit requirements. My healthcare implementation experience informed the workflow; the project gave me a way to work through those constraints in code.

## Architecture

![Patient Logger Architecture Diagram](/images/patient-logger/architecture.svg)

The system is structured to separate concerns between user interaction, business logic, and data enforcement.

The backend acts as the primary enforcement layer for authentication and authorization, while PostgreSQL Row Level Security ensures tenant isolation at the data layer.

This dual-layer approach reduces the risk of data leakage and simplifies application logic.

---

## The workflow

1. A clinician signs in with an admin or clinician role.
2. The system scopes patient records to the clinician's organization.
3. A task log records the patient, clinician, task type, and timestamp.
4. Users filter activity by patient, clinician, type, or date.
5. Administrators manage patient records; backend checks enforce permissions and task ownership.

## System Design Overview

Patient Logger is built as a layered clinical workflow system with clear separation between the interface, application logic, and data controls.

The React frontend is responsible for usability: guiding clinicians through task-oriented workflows, showing only role-appropriate actions, and keeping interactions fast and clear. The backend REST API acts as the main control layer, enforcing authentication, validation, and workflow rules before requests reach the database.

To reduce risk, tenant isolation is enforced at both the application and database layers. User identity and role checks happen in the API, while PostgreSQL Row Level Security ensures each hospital only accesses its own data. This dual-layer approach strengthens data boundaries and better reflects how real multi-tenant healthcare systems are designed.

At the data layer, the system centers on users, patients, and task logs, with each log tied to a patient record and clinical user context. This supports traceability, auditability, and cleaner ownership rules across the system.

Supporting services like Redis and Docker improve extensibility and operational consistency. Redis provides a foundation for future caching and performance improvements, while Docker ensures the application stack can be run and reset reliably across environments.

![Patient Logger menu screen](/images/patient-logger/login.jpg)

---

## Backend: architecture and intent

The backend is a Node.js REST API designed with modularity and safety in mind.

### Stack

- **Node.js 18**
- **Express 5**
- **PostgreSQL 15** (via `pg` pool)
- **Redis 7** (Dockerized)
- **JWT authentication** (`jsonwebtoken`)
- **Password hashing** (`bcryptjs`)
- **Validation** (`express-validator`)
- **Security middleware** (`helmet`, `cors`, rate limiting)
- **Testing**: `jest`, `supertest`

### Core structure

The API follows a modular layout:

- `app.js` initializes middleware, security layers, health checks, and routing
- Auth routes handle registration, login, and role enforcement
- Patient and task-log routes handle CRUD operations
- Middleware handles authentication, authorization, and request validation

Everything is structured to keep business logic readable and predictable.

![Patient Logger Log](/images/patient-logger/patient-task-log.jpg)

---

## Data model and multi-tenancy

The data model includes:

- **users**
- **patients**
- **task_logs**

To support multi-tenancy, a second migration introduces:

- `hospital_id` on core tables
- PostgreSQL **Row Level Security (RLS)** policies
- A session-level `app.current_hospital_id` used to scope all queries

This ensures:

- Users only see data belonging to their organization
- Isolation is enforced at the database level, not just in application logic

A trigger automatically assigns `hospital_id` on new task logs based on the associated patient, reducing application-side risk.

---

## Core API behavior

- **Authentication**
  - JWT-based login and registration
  - Role-based access (admin vs clinician)

- **Patients**
  - Admin-only create, update, and delete
  - MRN uniqueness scoped per hospital

- **Task logs**
  - Create, update, delete, and query
  - Filterable by patient, clinician, type, and date
  - Ownership checks enforced server-side

![Patient Logger dashboard](/images/patient-logger/dashboard.jpg)

### Key Design Decisions & Tradeoffs

### Enforcing tenant isolation at the database layer (RLS)

Tenant isolation is handled using PostgreSQL Row Level Security, scoped by a session-level `hospital_id`.

- **Why:** Prevents cross-tenant data access even if application logic fails
- **Tradeoff:** Adds complexity when debugging queries and requires careful policy design

This approach prioritizes safety over simplicity, which aligns with how sensitive data systems are typically designed.

---

### Dual-layer authorization (API + database)

Authorization is enforced in both the API layer (JWT + role checks) and the database layer (RLS).

- **Why:** Defense-in-depth reduces reliance on any single layer of protection
- **Tradeoff:** Requires maintaining consistency between application logic and database policies

This mirrors patterns used in systems where data integrity is critical.

---

### Server-side ownership enforcement

All ownership checks (e.g., who can modify a task log) are handled on the backend rather than trusted from the client.

- **Why:** Prevents client-side manipulation and ensures consistent enforcement
- **Tradeoff:** Increases backend complexity and requires more explicit validation logic

This keeps the system predictable and secure as it scales.

---

### Containerized environment with Docker

The application, database, and Redis are all run in containers using `docker-compose`.

- **Why:** Ensures consistent environments and enables fast iteration on schema and infrastructure changes
- **Tradeoff:** Adds initial setup overhead and requires coordination across services

This significantly reduced environment-related issues and made experimentation safer.

---

### Centralized API layer for frontend communication

All frontend requests go through a single configured Axios client with interceptors.

- **Why:** Standardizes error handling, auth token management, and request structure
- **Tradeoff:** Adds abstraction that can obscure request-level debugging if not well understood

This made the system easier to extend and debug over time.

---

### Keeping the system intentionally scoped

The system focuses on core workflows (patients, users, task logs) rather than attempting full clinical complexity.

- **Why:** Allows deeper focus on correctness, data modeling, and system behavior
- **Tradeoff:** Does not yet reflect full integration complexity (e.g., external systems, real-time feeds)

This keeps the project aligned with its goal: modeling core patterns found in production systems without unnecessary overhead.


---

## What’s next

If I continue evolving this project:

- Add deeper test coverage for auth and tenant boundaries
- Introduce structured logging and metrics
- Add token refresh support
- Improve accessibility for clinical environments
- Expand patient detail views and workflows

---

For implementation details, explore the two project repositories:

- **Backend:** <a href="https://github.com/hsivasambu/patient-task-logger-backend" target="_blank" rel="noopener noreferrer">patient-task-logger-backend</a>
- **Frontend:** <a href="https://github.com/hsivasambu/patient-task-logger-frontend" target="_blank" rel="noopener noreferrer">patient-task-logger-frontend</a>

---
