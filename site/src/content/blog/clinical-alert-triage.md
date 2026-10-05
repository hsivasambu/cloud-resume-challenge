---
title: "Clinical Alert Triage Assistant: AI Explanations with Human Oversight"
description: "A simulated alert workflow with deterministic severity rules, AI explanations, human overrides, and an audit trail."
date: 2026-05-06
tags: ["healthcare", "AI", "system design", "reflection"]
draft: false
---

## Project at a glance

- **Problem:** Clinical alerts can arrive without enough context to understand priority and routing.
- **My role:** Designed and built a personal prototype informed by healthcare implementation experience.
- **Delivered:** Six simulated alert types, deterministic triage rules, optional AI explanations, human review, and an audit log.
- **Tradeoff:** Used simulated inputs to explore the review workflow before adding hospital integrations.
- **Validation:** The repository includes tests for severity rules, AI fallback, review actions, and persistence. These are software tests, not clinical validation.
- **Status:** Live demonstration using simulated data; not a clinical system.

[Try the demo](https://clinical-alert-triage-t7t1.vercel.app/) · [Source and tests](https://github.com/hsivasambu/clinical-alert-triage)

## The problem I chose

Conversations with nurses and clinical staff during implementations made me interested in how alerts earn attention and trust. A priority label alone does not explain which evidence mattered or why an alert was routed to a particular team.

I wanted to explore whether AI could explain that context without controlling the triage decision. The prototype covers tachycardia, low oxygen saturation, infusion pump alarms, nurse calls, fall risk, and sepsis screening.

![Simulated alert queue](/images/alert-triaging/alerts_Table.jpg)

## Keeping authority separate from explanation

The rules engine assigns severity, and deterministic routing selects the destination. The LLM generates narrative fields: a summary, rationale, contributing factors, uncertainty notes, and recommended checks.

The decision layer keeps priority, route, and rule trace under deterministic control. The model cannot raise or lower priority, or change routing. Invalid, absent, or low-confidence output leads to rules-only mode.

The confidence value is a model estimate used as a fallback signal. It is not a clinically calibrated probability.

![Triage workflow](/images/alert-triaging/Flowchart.png)

This boundary was the main design decision. It gave the model a useful, limited job and let me inspect what happened when that layer was unavailable.

## Designing for review

I considered three audiences: bedside nurses reading an explanation, charge nurses reviewing escalation, and informatics or QA staff inspecting the decision history.

The interface exposes the rule trace alongside the explanation. A reviewer can accept a result, record an override, or submit feedback. The original triage result remains available with the subsequent actions.

Feedback capture is a review mechanism; recording feedback does not itself retrain the model or change its future responses.

![Explanation panel](/images/alert-triaging/Alert_Explanation.jpg)

## Scope and validation

I left out EHR connections and streaming feeds. JSON inputs and a focused review flow made it possible to work on decision boundaries without adding integration dependencies first.

The committed tests cover rule behavior, low-confidence and unavailable explanations, preserved priority and routing, human review, and stored records. The live interface provides a way to inspect those behaviors, but it does not establish that the thresholds or workflow are suitable for patient care.

The demo uses SQLite. Its current hosting has an ephemeral filesystem, so records can be lost when the service restarts. Sample alerts are reseeded; the audit log is not a production retention system.

## What I would do next

I would add a scenario-based evaluation view and make post-review state clearer in the queue. Moving beyond a demo would need persistent storage, identity and access controls, integration testing, and clinical validation.

The project taught me to define the model's authority and failure behavior before adding the AI feature. That made the implementation easier to review and kept the MVP focused.
