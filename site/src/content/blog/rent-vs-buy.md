---
title: "Rent vs Buy as a Product: Engineering, UX, and Monetization"
description: "A stab at vibe coding"
date: 2025-10-03
tags: ["vibe coding", "claude coding", "product"]
draft: true
---

## Product Case Study

This project started with a simple observation: most rent vs buy tools are not designed to help users think clearly. As someone looking to purchase their first home in Toronto's very challenging housing market, this one hit close to home. Existing tools often hide assumptions, skip local rules, and present outputs without enough context to build trust. I wanted to build a platform that makes trade-offs explicit, encourages financial intuition, and can evolve into a real business.

## Problem Definition

Most rent vs buy calculators:

- Oversimplify assumptions and hide the underlying logic.
- Ignore local tax rules and opportunity cost.
- Provide results without explaining why the numbers move.

That gap creates a trust problem. Users cannot adjust assumptions or understand how outputs change, so the tool feels like a black box. The core goal here was to make the trade-offs explainable and adaptable for real decision-making.

## Product and UX Decisions

The experience is designed around progressive disclosure:

- Simple default inputs for casual users who want a fast answer.
- Advanced assumptions available for power users who want control.

Real-time feedback and immediate recalculation reinforce intuition. Every change in a variable leads to an instant update so users can see cause and effect.

Explainability was a first-class requirement. Inline explanations and tooltips focus on financial meaning, not just formulas.

The goal was not just accuracy, but financial intuition.

## Technical Architecture

This is a frontend-first product, so the framework choice prioritizes performance and developer ergonomics while keeping the app easy to extend. State management is optimized for fast recalculation without adding needless complexity.

Key architecture decisions:

- The financial engine is separated from UI components to keep business logic portable.
- Input validation and edge-case handling (rate = 0, negative equity, unusual timelines) are treated as first-order concerns.

I separated the financial engine from the UI so the model could later power APIs, premium features, or embedded tools.

## Financial Modeling Logic

The model focuses on assumptions that materially change outcomes:

- Opportunity cost of the down payment.
- Rent growth vs. home appreciation.
- Tax treatment for renting vs. ownership.
- Time-value of money.

Every assumption is user-modifiable because financial conclusions are only meaningful when the assumptions are explicit.

## Monetization and Product Evolution

From day one, the architecture is designed for monetizable expansion without rewriting core logic. Possible paths include:

- Freemium: free core calculator, paid advanced scenarios (multiple properties, region-specific tax rules).
- B2B: white-label version for mortgage brokers or real estate firms.
- Affiliate: referrals to mortgage providers or financial advisors.
- Data insights: anonymized market trends for research and lead generation.

The architecture was intentionally designed to support premium features without re-writing core logic.

## Metrics and Learnings

Early feedback suggested that users struggled to understand which assumptions mattered most, so default values were adjusted and explanatory copy was tightened. Performance also improved after reducing recalculation overhead, keeping the experience instantaneous even with advanced inputs enabled.

## Links

- Live demo: [Placeholder](https://example.com/live-demo)
- GitHub repository: [Placeholder](https://example.com/github-repo)
- Technical deep-dive (optional): [Placeholder](https://example.com/technical-deep-dive)
