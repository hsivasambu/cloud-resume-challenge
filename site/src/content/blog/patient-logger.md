---
title: "Building a Patient Logger: Designing a Full-Stack System with Real Constraints"
description: "Personal projects relating to professional work"
date: 2025-07-22
tags: ["healthcare", "web design", "reflection"]
draft: false
---

After building a small game to reconnect with hands-on coding, I wanted to tackle something closer to real-world systems work. Something with structure, rules, tradeoffs, and consequences if done poorly. Inspiration for this project was drawn from the healthcare systems I work with everyday as a project manager for Stryker.

### Healthcare at an inflection point

Healthcare is at a quiet but meaningful inflection point. Clinicians and operational teams are asking more from the software they rely on every day. Not just stability, but **better usability, faster workflows, fewer clicks, cleaner integrations, and less downtime**. Many legacy systems have been deeply embedded for years, but they were built for a different era—one where flexibility, developer experience, and rapid iteration were not priorities.

At the same time, a new wave of healthcare technology companies is emerging, built on modern infrastructure and product-first thinking. Companies like **Notable**, **Abridge**, **Commure**, **Innovaccer**, and **Particle Health** are rethinking how clinical data flows, how users interact with systems, and how quickly software can adapt to real-world care environments.

What sets these newer platforms apart isn’t just technology—it’s philosophy:

- **API-first and integration-friendly architectures**
- **User experiences designed around clinicians, not legacy workflows**
- **Cloud-native infrastructure that scales and recovers gracefully**
- **Faster iteration cycles driven by real user feedback**
- **Security and compliance built in from day one**

In hospital environments, tracking patient-related tasks is often fragmented across multiple systems, increasing the risk of missed actions and poor visibility across care teams.

This project explores how a centralized, role-aware system could improve reliability, auditability, and coordination in clinical workflows.

---

That led to this **Patient Logger** app — A multi-tenant clinical task tracking system designed to model how healthcare applications handle user roles, data isolation, and auditability. The system is intentionally scoped, but designed using patterns found in production healthcare platforms. Think Epic Rover lite. Rover operates in a high-stakes environment with real patients, regulatory requirements, and deep integration with clinical data.

My Patient Logger doesn’t do all of that — but it implements the same core patterns: patient-linked task logs, authenticated clinical users, and clear, auditable records of actions. It’s a sandboxed way to explore how such systems behave before tackling full interoperability with real clinical platforms.

This project spans both backend and frontend, with a strong focus on correctness, clarity, and future extensibility.

---

## Architecture

![Patient Logger Architecture Diagram](/images/patient-logger/architecture.svg)

The system is structured to separate concerns between user interaction, business logic, and data enforcement.

The backend acts as the primary enforcement layer for authentication and authorization, while PostgreSQL Row Level Security ensures tenant isolation at the data layer.

This dual-layer approach reduces the risk of data leakage and simplifies application logic.

---

## Project overview

Patient Logger models core healthcare workflows around patients, clinicians, and task logs, with a focus on access control, data integrity, and auditability.
It models real constraints found in healthcare systems such as role-based access, tenant isolation, and data integrity.

The system is intentionally split into:

- **A backend REST API** focused on security, validation, and data ownership
- **A frontend UI** focused on clarity, speed, and usability in clinical workflows

## How the system works

At a high level, Patient Logger supports a simple clinical workflow: tracking patient-related tasks in a structured and auditable way.

A typical flow looks like this:

1. A clinician logs into the system and is authenticated based on their role (admin or clinician)
2. The clinician views a list of patients within their organization
3. Tasks can be created for a patient, such as logging an action, observation, or update
4. Each task is recorded with a timestamp, associated clinician, and task type
5. Task logs can be filtered and reviewed to understand recent activity and patient history

Administrators have additional permissions to create and manage patient records, while clinicians focus on interacting with task logs.

All actions are tied to both a user and a patient, creating a clear and auditable record of activity across the system.

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

## ![Patient Logger Log](/images/patient-logger/patient-task-log.jpg)

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

## ![Patient Logger dashboard](/images/patient-logger/dashboard.jpg)

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

## What this project demonstrates

- Designing multi-tenant systems with strong data isolation
- Applying backend-enforced security patterns
- Building end-to-end systems aligned with real-world constraints
- Translating healthcare workflows into system design

---

## What’s next

If I continue evolving this project:

- Add deeper test coverage for auth and tenant boundaries
- Introduce structured logging and metrics
- Add token refresh support
- Improve accessibility for clinical environments
- Expand patient detail views and workflows

---

## Final thoughts

This project sits at the intersection of engineering discipline and practical design. It reinforced that good systems aren’t just functional — they’re understandable, predictable, and safe to evolve.

---

For implementation details, explore the two project repositories:

- **Backend:** <a href="https://github.com/hsivasambu/patient-task-logger-backend" target="_blank" rel="noopener noreferrer">patient-task-logger-backend</a>
- **Frontend:** <a href="https://github.com/hsivasambu/patient-task-logger-frontend" target="_blank" rel="noopener noreferrer">patient-task-logger-frontend</a>

---
