---
title: "Patient Logger: Clinical Tasks and Access Control"
description: "A clinical task-tracking prototype with server-side permissions and an unfinished multi-tenant extension."
date: 2025-07-22
tags: ["healthcare", "web design", "reflection"]
draft: false
---

## Project at a glance

- **Goal:** Explore patient-linked task tracking and server-side access control.
- **My role:** Built a personal full-stack prototype informed by my healthcare implementation work.
- **Delivered:** A React interface, Express API, PostgreSQL data model, authentication, and task ownership checks.
- **Tradeoff:** Kept the workflow small; hospital integrations and real-time feeds are out of scope.
- **Status:** Prototype. Multi-tenancy is an extension in progress, not a verified isolation guarantee.

[Backend](https://github.com/hsivasambu/patient-task-logger-backend) · [Frontend](https://github.com/hsivasambu/patient-task-logger-frontend)

## The workflow

A clinician signs in, selects a patient, and records a task with a description and completion time. The log retains the patient and user association so activity can be filtered by patient, clinician, task type, or date.

Administrators manage patient records. Task updates check whether the requester is the creator or an administrator; deletion is administrator-only. These checks happen in the API rather than relying on which controls the interface shows.

![Patient Logger dashboard](/images/patient-logger/dashboard.jpg)

## Architecture and access control

The React interface calls a Node.js/Express API backed by PostgreSQL. JWT authentication identifies users; password hashing, input validation, rate limiting, and security middleware support the API.

Docker Compose provisions PostgreSQL and Redis for local development. Redis is included in the environment, but the backend has no Redis client integration yet. It is not an implemented cache.

![Patient Logger architecture](/images/patient-logger/architecture.svg)

The diagram describes the intended architecture, including the multi-tenant extension. It should be read alongside the implementation status below.

## Multi-tenancy: the unfinished boundary

The repository includes a migration adding hospitals, `hospital_id` fields, and PostgreSQL Row Level Security policies. It also includes hospital-context middleware and a separate multi-tenant patient router.

Those pieces are not fully connected in the default application: it still mounts the original patient router, and the task-log router uses the original authentication middleware. Adding policies to a migration is not enough to demonstrate isolation across the complete request path.

Before claiming that boundary works, I need to wire the routes together, verify the database role and connection-scoped hospital context, and test cross-hospital access. That is the next meaningful milestone for this project.

## Decisions and lessons

**Enforce ownership on the server.** The API uses the authenticated user to associate and authorize task updates. Hiding an edit button is not an access-control boundary.

**Keep the workflow narrow.** Patients, users, and task logs provided enough scope to explore data relationships and permissions without attempting an EHR integration.

**Separate configuration from proof.** Jest and Supertest are dependencies, but the repository does not yet contain a committed boundary test suite. The next step is evidence that the permission and tenant rules work, not another feature.

![Patient task log](/images/patient-logger/patient-task-log.jpg)

## Next steps

Connect and test the multi-tenant request path, add authentication and ownership tests, and improve token handling and operational logging. The app remains a learning prototype rather than a clinical deployment.
