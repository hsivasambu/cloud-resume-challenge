---
title: "Part 2: From Static to Stateful Systems"
description: "Adding a serverless backend and visitor counter to the Cloud Resume Challenge"
date: 2025-08-20
tags: ["cloud", "aws", "serverless", "architecture"]
draft: false
---

The first version of this project worked. It loaded quickly, resolved through DNS, and was globally accessible through a CDN. It looked like a real system.

Every request returned the same thing. There was no memory, no state, no way for the system to reflect anything about its users or its own behavior. It was essentially the same as hosting a photo of a duck.

That limitation became clear the moment I tried to answer a simple question:

**How many people have visited this site?**

---

## Why “Dynamic” Changes Everything

Adding a visitor counter sounds trivial from a programming perspective. Increment a variable is probably one of the very first tasks you do when learning coding. But this was a little different than x = x+1...

The moment a system needs to _remember something_, a few fundamental problems appear:

- Where does that data live?
- How is it updated safely?
- What happens if multiple users hit it at the same time?
- How do you expose it without breaking the simplicity of the frontend?

This is the transition point from static infrastructure to application design. You are no longer just serving files. You are managing state, concurrency, and data integrity.

---

## Designing the Simplest Possible Backend

Instead of jumping straight into complexity, I constrained the problem:

- One piece of data: a single counter
- Two operations:
  - **Read the current count**
  - **Increment the count**

That translates cleanly into an API:

- `GET /count` → returns current value
- `POST /count` → increments and returns updated value

This API becomes the contract between the frontend and the system. Everything else is implementation detail.

---

## Choosing Serverless on Purpose

There are many ways to build this. A small server, a container, even a managed backend service.

The AWS Cloud Resume Challenge Guidebook recommends serverless for one reason: **alignment with the problem.** (And to understand how to use AWS Lambda)

This system:

- Has unpredictable traffic
- Requires minimal compute
- Doesn’t justify managing infrastructure

Using AWS Lambda and API Gateway removes entire categories of concern:

- No servers to provision
- No scaling rules to tune
- No idle resources to pay for

The tradeoff is giving up some control in exchange for simplicity and speed. Serverless applications were a new tool for me, coming from a world of legacy healthcare applications and bare metal servers. The lack of overhead was refreshing to say the least.

---

## The Data Layer: Rethinking “Databases”

For storage, I used DynamoDB.

No need to overcomplicate this, its just a simple array. Just a key and a value.

That changes how you think about data:

- You model access patterns first, not tables
- You optimize for predictable reads and writes
- You accept constraints in exchange for scale and performance

The entire “database” becomes a single item:

```json
{
  "id": "visitor_count",
  "count": 1234
}

---
```

## The Hard Part Isn’t the Code

Incrementing a number is easy. Its the logistics that are tricky.

Two users hitting the endpoint at the same time introduces a subtle problem:

- Both read the same value
- Both increment
- One update overwrites the other

This is where distributed systems thinking starts to matter, even for something this small.

The solution is to avoid read then write patterns and use atomic updates. DynamoDB supports this natively, which means the database guarantees correctness without requiring coordination in the application layer.

This was the first time the system forced me to think about consistency rather than just functionality.

---

## Wiring It Together

At a high level, the flow now looks like this:

1. The frontend loads from CloudFront
2. JavaScript calls an API endpoint
3. API Gateway routes the request
4. Lambda executes the logic
5. DynamoDB stores and returns the result

Each component has a single responsibility. Together, they form a system.

<img
  src="/images/cloud-resume-challenge/serverless-backend-flowchart.svg"
  alt="Architecture diagram showing request flow from browser through API Gateway, Lambda, and DynamoDB"
  style="display: block; max-width: 100%; height: auto; margin: 16px auto;"
/>

What changed isn’t just the architecture. It’s the type of problem being solved.

---

## The Invisible Constraints

Adding this backend introduced new constraints that didn’t exist before:

- Latency: Every request now depends on multiple services
- Failure modes: What happens if Lambda fails? If DynamoDB throttles?
- Security: Who is allowed to call this API?
- Cost model: You now pay per request, not just for storage

None of these were concerns in Part 1. All of them are unavoidable now.

This is where systems stop being static diagrams and start behaving like real software.

---

## What This Stage Actually Taught

The technical implementation is straightforward, but the shift in thinking is not.

A few things became clear:

- State introduces complexity faster than expected
- Concurrency is a problem even at small scale
- Managed services don’t remove responsibility, they reshape it
- Good system design starts with constraints, not tools

Most importantly, I stopped thinking in terms of features and started thinking in terms of system behavior under load, failure, and change.

---

## Where This Leads Next

At this point, the system works. It has:

- A globally distributed frontend
- A serverless backend
- A persistent data layer

But it still has a major weakness.

Everything was created manually.

If this system needed to be rebuilt, replicated, or handed off to another team, there would be gaps. Hidden configuration. Implicit knowledge.

That’s the next problem to solve.
