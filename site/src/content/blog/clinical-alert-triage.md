---
title: "Clinical Alert Triage Assistant: AI Explanations with Human Oversight"
description: "A simulated alert workflow with deterministic severity rules, AI explanations, human overrides, and an audit trail."
date: 2026-05-06
tags: ["healthcare", "AI", "system design", "reflection"]
draft: false
---

## Project at a glance

- **Problem:** Clinical alerts often arrive without enough context to understand priority and routing.
- **My role:** Designed and built a personal prototype, informed by my healthcare implementation experience.
- **Key tradeoff:** Used six simulated alert types and JSON inputs to focus on explanation and review before adding hospital integrations.
- **Delivered:** A live demo with a rules engine, structured explanations, rules-only fallback, human overrides, feedback capture, and an audit log.
- **Validation focus:** Severity floors, malformed or unavailable model output, review actions, and preservation of the decision trail. The demo makes these workflows inspectable; this write-up does not report a formal clinical evaluation.
- **Status and limitations:** Demonstration MVP using simulated data. No real EHR integration or validated patient-care outcomes.

[Try the live demo](https://clinical-alert-triage-t7t1.vercel.app/)

My experience implementing healthcare communication systems shaped this project. Conversations with clinical staff highlighted a recurring concern: alerts need context that people can inspect and trust. I explored how an AI explanation layer could support that need while leaving severity constraints and review authority with rules and humans.

## The Product Problem

**Can AI help make clinical alerts easier to understand while keeping deterministic rules and human review in control?**

For this MVP, I focused on six simulated alert types:

- telemetry tachycardia
- low oxygen saturation
- infusion pump alarm
- nurse call escalation
- fall-risk alert
- sepsis screening

Each alert needed to produce a clear triage output:

- baseline severity from rules
- final priority
- destination or response team
- structured explanation
- confidence level
- rules vs. AI indicator
- audit log entry

![Alert triage table](/images/alert-triaging/alerts_Table.jpg)

The system was designed as decision support, not autonomous decision-making. That may sound like a small distinction, but it shaped almost every design decision that followed.

## The Key Design Decision

The most important decision was separating **authority** from **explanation**.

In this system:

- The rules engine defines the minimum severity.
- The LLM writes a structured explanation.
- The decision layer enforces guardrails.
- The human accepts, overrides, or gives feedback.
- The audit log records what happened.

The LLM does not get to quietly become the decision-maker.

If a rule says an alert is critical, the LLM cannot downgrade it. If the model output is malformed, missing, or low confidence, the system falls back to rules-only mode. If a human overrides the result, the original system decision is still preserved for review.

That became the operating principle for the project:

**Rules are the safety floor. AI is the communication layer. Humans stay in control.**

## Why Scope Control Mattered

It would have been easy to chase realism too early.

Real hospital integrations would have made the demo feel more authentic. Streaming alert pipelines would have been interesting. EHR data would have added depth.

But all of that would have pulled the project away from the core question.

Instead, I chose simulated JSON alerts and a focused workflow. That kept the project centered on the behavior I wanted to test:

- Can the system classify alerts consistently?
- Can it explain why an alert was prioritized?
- Can it show uncertainty clearly?
- Can a human review or override the result?
- Can every action be audited?

In a real clinical environment, integrations, data feeds, identity management, security, and validation would all matter. For this MVP, the better choice was to prove the core workflow before adding operational complexity.

## The Users I Designed Around

I framed the system around three user groups.

**Bedside nurses** need quick, readable explanations. They do not need a wall of technical reasoning while managing an active shift.

**Charge nurses and rapid response teams** need clear escalation signals and routing rationale.

**Clinical informatics and QA teams** need auditability. They need to know what the system saw, what rules fired, what the AI generated, and how humans responded. They also need the ability to adjust the model responses by providing feedback and cues to the LLM.

Thinking through those users was a helpful exercise that pushed the project away from being a backend-only demo. The explanation panel, override flow, feedback capture, and audit log all came from asking who would actually need to trust, use, or review the system.

## What the System Does

At a high level, the workflow looks like this:

![System workflow flowchart](/images/alert-triaging/Flowchart.png)

For example, if an oxygen saturation alert crosses a critical threshold, the rules engine sets the severity floor. The LLM can help explain the contributing factors and uncertainty, but it cannot make the alert less urgent.

That type of constraint makes the AI feature more credible, not less.

<table style="width: 100%; border-collapse: collapse; border: 1px solid white;">
  <thead>
    <tr>
      <th style="width: 22%; padding: 10px 14px; border: 1px solid white; text-align: left;">System Component</th>
      <th style="padding: 10px 14px; border: 1px solid white; text-align: left;">Role in the Workflow</th>
      <th style="padding: 10px 14px; border: 1px solid white; text-align: left;">Explicit Boundary</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 10px 14px; border: 1px solid white;"><strong>Rules Engine</strong></td>
      <td style="padding: 10px 14px; border: 1px solid white;">Sets the severity floor using deterministic alert logic and predefined clinical thresholds.</td>
      <td style="padding: 10px 14px; border: 1px solid white;">Does not generate natural-language explanations or interpret nuance beyond the rules.</td>
    </tr>
    <tr>
      <td style="padding: 10px 14px; border: 1px solid white;"><strong>LLM Explanation Layer</strong></td>
      <td style="padding: 10px 14px; border: 1px solid white;">Turns alert details, rule outputs, and uncertainty into a readable explanation.</td>
      <td style="padding: 10px 14px; border: 1px solid white;">Cannot downgrade critical alerts, change rule-based severity, or make clinical decisions.</td>
    </tr>
    <tr>
      <td style="padding: 10px 14px; border: 1px solid white;"><strong>Decision Layer</strong></td>
      <td style="padding: 10px 14px; border: 1px solid white;">Enforces guardrails, validates model output, and triggers fallback behavior when needed.</td>
      <td style="padding: 10px 14px; border: 1px solid white;">Does not rely on the LLM without checks or allow unsafe outputs to pass through.</td>
    </tr>
    <tr>
      <td style="padding: 10px 14px; border: 1px solid white;"><strong>Human Reviewer</strong></td>
      <td style="padding: 10px 14px; border: 1px solid white;">Reviews the alert, accepts or overrides the output, and adds feedback when appropriate.</td>
      <td style="padding: 10px 14px; border: 1px solid white;">Does not have to blindly accept the system's recommendation.</td>
    </tr>
    <tr>
      <td style="padding: 10px 14px; border: 1px solid white;"><strong>Audit Log</strong></td>
      <td style="padding: 10px 14px; border: 1px solid white;">Preserves the rule output, AI explanation, final priority, human action, and override history.</td>
      <td style="padding: 10px 14px; border: 1px solid white;">Does not make recommendations or alter the decision trail after the fact.</td>
    </tr>
  </tbody>
</table>

## The Explainability Standard

Healthcare professionals are understandably cautious about AI systems that influence patient care. Trust is especially difficult when a model behaves like a black box or produces outputs that cannot be validated against clinical reasoning.

For that reason, I designed the LLM feature around explanation rather than instruction. The goal was not to tell nurses what to do. The goal was to make the system's reasoning visible enough for a human to evaluate it quickly.

Every explanation needed a consistent structure:

1. Summary
2. Key factors
3. Routing rationale
4. Uncertainty
5. Rule trace
6. Verification guidance

<div style="text-align: center;">
  <img src="/images/alert-triaging/Alert_Explanation.jpg" alt="Alert explanation output" />
</div>

This became one of the biggest lessons from the project.

"Explainability" is vague until you define what a good explanation must contain. A summary alone is not enough. A confidence number alone is not enough. A model-generated paragraph without a rule trace is not enough.

The explanation has to help a human understand:

- what happened
- what evidence mattered
- why the alert was routed a certain way
- what remains uncertain
- which deterministic rules fired
- what should be verified next

That structure made the AI output easier to evaluate and much easier to design around in the UI.

## Lessons and next steps

The main lesson was to define the model's authority before choosing the model. Severity floors, fallback behavior, and review history are requirements for the workflow, rather than features to add after the AI integration.

The next step would be to evaluate the prototype against a documented scenario set, including malformed outputs, unavailable AI, and human overrides. Moving beyond a demo would also require clinical validation, security review, identity controls, and integration testing. No clinical performance benefit has been measured here.

[Explore the Clinical Alert Triage Assistant](https://clinical-alert-triage-t7t1.vercel.app/)
