---
title: "Building a Patient Logger: Designing a Full-Stack System with Real Constraints"
description: "Personal projects relating to professional work"
date: 2025-09-22
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

This shift is raising expectations across the industry. Healthcare teams increasingly expect software to feel modern, reliable, and responsive—because their work depends on it. Building systems with that mindset requires rethinking how we design, deploy, and evolve software from the ground up.

---

That led to this **Patient Logger** app — a very simple patient task tracking application designed to simulate how clinicians might log care activities in a controlled, secure environment. The goal was not to build a production healthcare app, but to design something that _behaves_ like one: role-aware, auditable, and structured enough to scale. Think Epic Rover lite. Rover operates in a high-stakes environment with real patients, regulatory requirements, and deep integration with clinical data.

My Patient Logger doesn’t do all of that — but it implements the same core patterns: patient-linked task logs, authenticated clinical users, and clear, auditable records of actions. It’s a sandboxed way to explore how such systems behave before tackling full interoperability with real clinical platforms.

This project spans both backend and frontend, with a strong focus on correctness, clarity, and future extensibility.

---

## Project overview

Pixel Logger is a full-stack application designed to manage:

- Clinicians
- Patients
- Task logs tied to clinical workflows

It models real constraints found in healthcare systems such as role-based access, tenant isolation, and data integrity.

The system is intentionally split into:

- **A backend REST API** focused on security, validation, and data ownership
- **A frontend UI** focused on clarity, speed, and usability in clinical workflows

**Caveat:** This project is significantly larger than anything I’ve built solo before. To help bootstrap the structure and initialize files, I used **Claude Code** as an assistive tool. That said, the **architecture, logic, tradeoffs, and design decisions were driven by my own reasoning**, informed by research into current industry standards, modern healthcare platforms, and real-world system design patterns. The goal was not automation, but acceleration — using tools to move faster while staying deeply involved in every technical decision.

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

## Why Docker mattered

Docker was a central part of this project.

Using `docker-compose`, I containerized:

- PostgreSQL
- Redis
- The application runtime

This provided:

- Consistent local environments
- No “works on my machine” drift
- Easy resets for schema experiments
- Confidence that the app behaves the same across machines

Migrations are auto-run during container startup, making schema evolution fast and repeatable.

Scripts like:

- `db:up`
- `db:down`
- `db:reset`

made iteration safe and fast.

---

## Frontend: making complexity usable

The frontend focuses on clarity, speed, and usability in a clinical context.

### Stack

- **React 19**
- **React Router v7**
- **Material UI v7 (MUI)**
- **Emotion**
- **Axios**
- **date-fns**

### Architecture

- `App.js` sets global theme, routing, and layout
- `AuthContext` manages auth state with `useReducer`
- Auth tokens persist in `localStorage`
- API calls go through a centralized Axios client with interceptors

The UI uses:

- Role-based route guards
- Consistent layout via AppBar + responsive Drawer
- Automatic redirects for unauthorized access

---

## Core UI flows

- **Login & Register**

  - Validation, error feedback, demo credentials
  - Clean redirect flow on auth state changes

- **Dashboard**

  - Summary metrics (patients, tasks, activity)
  - Quick-access actions
  - Recent activity previews

- **Patient management**

  - Searchable table view
  - Detail preview modal
  - Admin-only create/edit/delete
  - MRN generation helpers

- **Task logs**
  - Color-coded task types
  - Clear timestamps and clinician attribution
  - Empty states for clarity

---

## Design decisions I’m glad I made

- **Clean visual hierarchy**  
  Medical UIs need clarity before creativity.

- **Role-aware navigation**  
  Users only see what they need, when they need it.

- **Centralized API layer**  
  Made debugging and iteration dramatically easier.

- **Explicit error states**  
  Silent failures are dangerous in clinical tools.

## ![Patient Logger Log](/images/patient-logger/patient-task-log.jpg)

## Challenges worth calling out

### 1. Multi-tenant boundaries

Designing RLS policies that were flexible but safe required careful thought. This was one of the most valuable learning areas of the project, and relevant for me as I have worked with several large healthcare systems that all vary how they handle multi-tenancy setup.

### 2. Docker + environment alignment

Making sure environment variables matched across Node, Postgres, and Docker Compose took iteration.

### 3. Auth edge cases

Token expiration, invalid states, and role enforcement exposed subtle bugs early.

### 4. UI clarity vs feature depth

Balancing simplicity with functionality required constant pruning.

---

## What I learned

This project reinforced several things:

- Docker is a force multiplier for local development
- Security should be designed early, not patched later
- Multi-tenant thinking changes how you model everything
- Clean boundaries make systems easier to reason about

Most importantly, it reminded me how much clarity comes from building end to end.

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
