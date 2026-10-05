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

[Try the demo](https://clinical-alert-triage-t7t1.vercel.app/) · [View repository and tests](https://github.com/hsivasambu/clinical-alert-triage)

## The problem I chose

Conversations with nurses and clinical staff during implementations made me interested in how alerts earn attention and trust. A priority label alone does not explain which evidence mattered or why an alert was routed to a particular team.

I wanted to explore whether AI could explain that context without controlling the triage decision. The prototype covers tachycardia, low oxygen saturation, infusion pump alarms, nurse calls, fall risk, and sepsis screening.

![Simulated alert queue](/images/alert-triaging/alerts_Table.jpg)

## Keeping authority separate from explanation

The rules engine assigns severity, and deterministic routing selects the destination. The LLM generates narrative fields: a summary, rationale, contributing factors, uncertainty notes, and recommended checks.

The decision layer keeps priority, route, and rule trace under deterministic control. The model cannot raise or lower priority, or change routing. Absent output, invalid JSON, schema failures, or an explanation confidence score below 0.5 lead to rules-only mode. These checks validate structure and availability; they do not establish that the narrative is accurate or suitable.

The severity thresholds, routing choices, hard-coded rule-confidence values, and 0.5 explanation cutoff are illustrative and clinically unvalidated. The explanation score starts as a model estimate and is capped by input-completeness heuristics. Neither score is a clinically calibrated probability.

![Triage workflow](/images/alert-triaging/Flowchart.png)

This boundary was the main design decision. It gave the model a useful, limited job and let me inspect what happened when that layer was unavailable.

## Designing for review

I considered three audiences: bedside nurses reading an explanation, charge nurses reviewing escalation, and informatics or QA staff inspecting the decision history.

The interface exposes the rule trace alongside the explanation. A reviewer can accept a result, record an override, or submit feedback. The original triage result remains available with the subsequent actions.

The [feedback handler](https://github.com/hsivasambu/clinical-alert-triage/blob/9be1db24153dc2e07a72d96fa515d7893b7a7559/backend/main.py) appends feedback to the audit record. It is not retrieved by the prompt builder, passed into generation, or used to retrain the model. It gives a reviewer evidence to inspect; it does not adjust subsequent explanations.

![Explanation panel](/images/alert-triaging/Alert_Explanation.jpg)

## The explanation format I am targeting

The target standard has six parts: **summary, key factors, routing rationale, uncertainty, rule trace, and verification guidance**. The interface is organized around those elements so a reviewer can compare narrative claims with the deterministic result.

The current rules-only fallback does not fully meet that standard. It retains the route and rule trace, but uses a placeholder summary and uncertainty note; rationale, factors, and recommended checks are empty. Keeping the decision available is useful, but a complete explanation during fallback remains work to do.

The [explanation panel](https://github.com/hsivasambu/clinical-alert-triage/blob/9be1db24153dc2e07a72d96fa515d7893b7a7559/frontend/src/components/ExplanationPanel.tsx) and [decision layer](https://github.com/hsivasambu/clinical-alert-triage/blob/9be1db24153dc2e07a72d96fa515d7893b7a7559/backend/decision_layer.py) show that difference between the intended format and the implemented fallback.

## A worked example from the code

I ran the repository's [simulated low-oxygen sample](https://github.com/hsivasambu/clinical-alert-triage/blob/9be1db24153dc2e07a72d96fa515d7893b7a7559/sample_data/alerts_low_spo2.json) through the rules engine and decision layer, without an LLM call. It contains SpO2 of 85%, one repeat, and a medical/surgical unit.

| Checkpoint | Observed output |
| --- | --- |
| Matched rule | `SPO2_LT_88`, the demo rule for SpO2 below 88% |
| Baseline and final priority | `Critical` |
| Final route | `Rapid Response Team` |
| Explanation mode | `rules_only` |
| Rule trace | `SPO2_LT_88`, preserved from the rules engine |
| Narrative fields | Placeholder summary; empty rationale, factors, and recommended checks |

These are prototype outputs, not a recommendation for handling a real patient. The useful implementation result is that losing the explanation layer leaves the same deterministic priority and route available, while visibly reducing the explanation's completeness.

## Scope and validation

I left out EHR connections and streaming feeds. JSON inputs and a focused review flow made it possible to work on decision boundaries without adding integration dependencies first.

The [explainer](https://github.com/hsivasambu/clinical-alert-triage/blob/9be1db24153dc2e07a72d96fa515d7893b7a7559/backend/llm_explainer.py) parses JSON and uses Pydantic to check required fields, basic types, non-empty strings/lists, and a confidence range of 0 to 1. Prompt instructions ask for explanation rather than diagnosis or treatment, but there is no semantic safety filter that guarantees unsuitable narrative content is rejected. A structurally valid explanation can still contradict the alert or make unsupported claims.

On October 4, 2026, I checked source snapshot [`9be1db2`](https://github.com/hsivasambu/clinical-alert-triage/tree/9be1db24153dc2e07a72d96fa515d7893b7a7559) using Python 3.13 on Windows and the repository's declared dependencies:

| Software check | Measured result |
| --- | --- |
| Existing suite, `python -m pytest -q` from `backend/` | 97 passed; 1 failed |
| Simulated low-oxygen sample, no model call | Critical priority and Rapid Response Team route; rules-only explanation |
| One synthetic narrative-mismatch probe | Schema accepted the payload and the decision layer used hybrid mode |

The failing test, `test_multiple_feedback_allowed`, expects a negative rating without a reason category to succeed. The current input schema requires that category and returns HTTP 422. That is a test/request-contract mismatch, not evidence that repeated valid feedback is unsupported.

For the mismatch probe, I supplied a schema-valid explanation describing a heart rate of 145 bpm to the low-oxygen sample, whose heart rate is 102 bpm. It passed the parser and appeared in hybrid mode. Priority and routing remained rules-controlled, but the contradictory narrative was not rejected. This was a deliberately supplied payload, not an observed model response or a measured model failure rate.

[View the evaluation record and probe input](/evidence/clinical-alert-triage-evaluation.json).

These measurements check software behavior with synthetic inputs and mocked model responses. I have not measured real-model explanation accuracy, unsafe-content frequency, clinician agreement, or clinical outcomes. Passing these checks does not validate the thresholds or workflow for patient care.

Known limits also include simulated inputs, no EHR or streaming integration, no calibrated confidence scores, and no feedback-to-generation loop.

The demo uses SQLite. Its current hosting has an ephemeral filesystem, so records can be lost when the service restarts. Sample alerts are reseeded; the audit log is not a production retention system.

## What I would do next

I would add a scenario-based evaluation view, assess narrative accuracy and safety with clinical reviewers, complete the rules-only explanation, and make post-review state clearer in the queue. Moving beyond a demo would need persistent storage, identity and access controls, integration testing, and clinical validation.

The project taught me to define the model's authority and failure behavior before adding the AI feature. That made the implementation easier to review and kept the MVP focused.
