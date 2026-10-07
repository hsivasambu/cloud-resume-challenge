---
title: "Integration Reliability Sandbox: When an Alert Gets Through but the Reply Doesn't"
description: "A working sandbox for API delivery failures, bounded retries, duplicate protection, and recovery that keeps the original history."
date: 2026-09-15
tags: ["system design", "APIs", "reliability", "reflection"]
draft: false
---

## Project at a glance

- **Problem:** API event delivery and ingestion can be hard to follow once work moves between systems. I wanted to visualize the path, demonstrate common failures, and show how each is handled.
- **My role:** Built a personal learning project to explore delivery behaviour through guided scenarios, recorded decisions and verification.
- **Delivered:** An event API, a PostgreSQL-backed delivery worker, a test receiver, and guided failure scenarios with an inspectable attempt history.
- **Tradeoff:** Kept the receiver inside the same application so failures are repeatable and visitors can see both sides of a delivery.
- **Status:** Live demonstration using synthetic alerts. It connects to no hospital system and sends nothing to people.

[Try the sandbox](https://integration-reliability-sandbox.onrender.com/) · [API reference](https://integration-reliability-sandbox.onrender.com/docs/)

## Why I built it

During healthcare implementations, someone eventually asks whether a message went through. That question sounds simple until the sending and receiving systems disagree. An API may have accepted a request without delivering it. A receiver may have completed its work without getting a reply back to the sender.

I wanted to understand what sits behind those differences: what a timeout tells us, when another attempt makes sense, and what prevents the same alert from being acted on twice. The sandbox makes those cases visible without needing a real integration or real patient data.

The case I kept coming back to was a late reply. The receiver records the alert, but the sender's timer runs out first. Giving up risks missing a delivery; sending again risks repeating work. A retry helps only if the receiver knows how to recognize the repeat.

## Follow an alert

The page starts with three editable examples: a service request, an equipment notification, and a team update. Sending one starts an anonymous demo session that lasts 24 hours. Each visitor has their own alerts and receiver settings.

Four guides cover normal delivery, recovery from a temporary outage, a reply that arrives too late, and a delivery that exhausts its automatic attempts. Each guide waits for evidence from the API before moving to its next step. Visitors can also change the receiver's behaviour themselves.

![Four guided scenarios covering normal delivery, temporary failure, duplicate protection and manual recovery](/images/reliability-sandbox/guided-scenarios.jpg)

*The guides change the test receiver and send synthetic alerts through the working API. The browser displays the results; it does not invent the failures.*

I would start with **Avoid processing twice**. It shows why a delivery acknowledgement and a processing record need separate labels.

## What the API promises

The application uses Node.js, Express and PostgreSQL, with a plain JavaScript frontend. The API, worker and mock receiver run in one web process on Render. The worker calls the receiver over HTTP, and PostgreSQL stores events, delivery jobs, attempts and receipts.

![Data flow from the browser to the event API, PostgreSQL delivery store, background worker and test receiver, with status polling back to the browser](/images/reliability-sandbox/data-flow.svg)

*PostgreSQL holds both the work waiting to be sent and the evidence of what happened. The test receiver is part of this application, not an external integration.*

The API accepts an alert with `POST /v1/events`. Before returning `202 Accepted`, it stores the event and its delivery job in one transaction. The response includes a URL for checking progress. A 202 means the request is stored and queued; the receiver has not necessarily seen it.

About once a second, the worker checks for due work. It claims a delivery, records an attempt, then sends the event to the receiver with a two-second timeout. The browser polls for delivery history and the receiver's receipt.

That gives the page three facts to report:

| Fact | Evidence |
| --- | --- |
| Accepted by the API | The event and delivery job were saved before the 202 response. |
| Acknowledged by the receiver | The sender received a successful HTTP reply. |
| Processed by the receiver | The receiver's receipt records a result. |

They usually line up. The late-reply scenario separates them.

## Reading the HTTP response

An HTTP code describes the response to one request. It helps decide what to do next, but does not tell the whole story of an alert. These are the codes worth watching in the sandbox:

<div class="sandbox-http-codes">
  <table>
    <thead><tr><th scope="col">Response</th><th scope="col">What it tells you</th><th scope="col">Next step</th></tr></thead>
    <tbody>
      <tr><th scope="row"><span class="http-code http-ok">200</span> OK</th><td>The request succeeded; a receiver reply acknowledges delivery.</td><td>Inspect the result.</td></tr>
      <tr><th scope="row"><span class="http-code http-ok">202</span> Accepted</th><td>The API stored and queued the alert. Delivery is still pending.</td><td>Follow the status URL.</td></tr>
      <tr><th scope="row"><span class="http-code http-fix">400</span> Bad request</th><td>The submitted input is invalid.</td><td>Correct the request.</td></tr>
      <tr><th scope="row"><span class="http-code http-fix">401</span> Unauthorized</th><td>The demo session token is invalid or expired.</td><td>Start a new session.</td></tr>
      <tr><th scope="row"><span class="http-code http-fix">404</span> Not found</th><td>The event is missing or outside this session.</td><td>Check the ID and session.</td></tr>
      <tr><th scope="row"><span class="http-code http-fix">409</span> Conflict</th><td>A submission key was reused with different content, or a replay conflicts with an existing one.</td><td>Resolve the conflict.</td></tr>
      <tr><th scope="row"><span class="http-code http-retry">408</span> Request timeout</th><td>The server reports a request timeout.</td><td>The worker can retry.</td></tr>
      <tr><th scope="row"><span class="http-code http-retry">429</span> Too many requests</th><td>A request limit has been reached.</td><td>Back off before retrying.</td></tr>
      <tr><th scope="row"><span class="http-code http-retry">503</span> Service unavailable</th><td>The test receiver is in its temporary-outage mode.</td><td>The worker schedules another try.</td></tr>
    </tbody>
  </table>
</div>

*Green: successful response. Rose: check the request or session. Amber: a retry may help.*

A sender timing out is different from receiving a `408`: no HTTP reply arrived at all. The worker retries either case within its attempt budget. Its delivery policy also retries other server errors; a rate limit on submitting a new alert does not itself create a delivery job.

## Processed, but not confirmed

In this scenario, the receiver commits its receipt and confirmation code, then delays its reply. The sender times out after two seconds and records the attempt as retryable. At that point the sender has no acknowledgement, even though the receiver has already processed the alert.

After a two-second retry delay, the worker sends the same event ID again. The receiver finds its existing receipt, counts the repeat, and returns the original result. The sender can now confirm delivery. There were two attempts and one processing result.

![Alert journey showing acceptance, confirmation on the second attempt and one repeat recognized by the receiver](/images/reliability-sandbox/duplicate-safe-delivery.jpg)

*The delivery service needed a second try. The receiving system's record shows that it processed the alert once.*

The history matters as much as the final green badge. It shows a timeout on the first attempt and a successful acknowledgement on the second, alongside the receiver's earlier processing record.

![Stored attempt history showing a timeout, scheduled retry, successful acknowledgement and duplicate recognition](/images/reliability-sandbox/timeout-attempt-history.jpg)

*A timeout tells the sender that no reply arrived in time. The separate receipt tells us what happened at the receiver.*

## Decisions that make recovery possible

**Keep the schedule in PostgreSQL.** Each delivery stores its next attempt time. A restart does not erase that schedule, and the worker can pick up overdue work when it resumes. Using the existing database kept the project small; the cost is polling and some delay before due work starts.

**Claim work with a lease.** A SQL statement uses `FOR UPDATE SKIP LOCKED` to claim a job atomically. The claim has a token and a 15-second lease. A worker whose lease expires cannot overwrite a newer worker's result. Expired attempts are recorded and re-queued within the attempt limit, so a crash does not leave a delivery stuck indefinitely. A crash can still cause another send, which is why receiver duplicate protection matters.

**Bound automatic retries.** Timeouts, network errors, HTTP 408, 429 and server errors can retry. Other client errors stop the delivery. The default budget is four attempts, with delays of 2, 4 and 8 seconds. The schedule avoids an immediate retry loop, but it has no jitter and does not yet honour `Retry-After`.

**Protect submission and processing separately.** A submission key is unique within a session. Repeating the same key and body returns the original event; changing the body while keeping the key returns `409`. That prevents a repeated API request from creating a second event. The receiver solves a different problem: its receipt is unique by session and event ID, so repeated deliveries of that event return the original result. Two genuine alerts with identical wording still get separate IDs.

**Add a replay instead of clearing history.** When automatic attempts stop, a manual replay creates a new delivery linked to the failed one. It keeps the same event ID and gets a fresh attempt budget. The original delivery and its attempts remain available, so recovery does not erase the failure being investigated.

![Manual replay history retaining four failed attempts and a successful linked delivery](/images/reliability-sandbox/manual-replay-history.jpg)

*After the receiver is restored, a new delivery succeeds. The four failed attempts stay in the original record.*

## What the checks cover

The project evidence includes 173 passing automated tests against PostgreSQL, covering concurrent submissions, competing workers, retry timing, restart recovery, duplicate recognition and replay history. They verify the controlled sandbox, not a hospital integration.

Two defects made the checks useful. A double click generated two submission keys and two alerts, prompting a short repeat guard. A waiting badge also appeared beside an attempt already sending because delivery state and attempts were read separately. The frontend reconciles those readings; one consistent database snapshot remains the better fix.

Both exposed behaviour that a normal successful send would have missed.

## What I learned

The biggest change was learning to separate acceptance, acknowledgement and processing. I used to think about delivery as one outcome. Building this made me ask which system knows what, and what evidence supports its answer. A timeout leaves uncertainty; a retry does not remove the need to protect against repeated work.

Idempotency, durable scheduling and leases became more concrete once I could see them fail. A submission key protects the creation of an event. A receiver's receipt protects its processing. A stored schedule survives a restart, while a lease lets another worker recover abandoned work. None of those pieces alone guarantees that an alert will eventually succeed.

As a technical project manager, I think this will help me write clearer acceptance criteria and ask better questions during integration testing. "One processing result, one repeat recognized, both attempts retained" is more useful than "the message went through." I would also ask who owns retries, what happens after the attempt budget runs out, and whether an operator can recover a delivery without erasing its history.

The project started to feel out of scope when I considered external receivers, always-on delivery and production operations. This receiver records its event ID and result together; an external system would need its own protection, particularly if it sends an email or changes another system. The free host can also sleep, taking the worker with it until a visit wakes the service. Keeping jobs in PostgreSQL preserves the work, but does not keep delivery running.

I kept those as boundaries of the learning project. Jitter, `Retry-After` support and a consistent history snapshot are sensible next improvements. Hospital connections, stronger operational guarantees and paid worker hosting would need their own requirements and testing. Working through the smaller system helped me see where that next conversation should begin.
