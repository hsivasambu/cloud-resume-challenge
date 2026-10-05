---
title: "Rent vs Buy as a Product: Engineering, UX, and Monetization"
description: "Draft notes for a transparent rent-versus-buy comparison tool."
date: 2025-10-03
tags: ["vibe coding", "claude coding", "product"]
draft: true
---

## Draft concept

I want to explore a rent-versus-buy tool while considering my first home purchase in Toronto. The useful question is how changing assumptions changes the comparison, rather than presenting a single answer as definitive.

## Proposed scope

A first version would expose purchase price, down payment, mortgage rate, rent, ownership costs, investment return, and time horizon. Users should be able to inspect those assumptions and compare scenarios.

The calculation model should be separate from the interface so its behavior can be tested. Zero interest rates, short time horizons, and negative equity need explicit handling.

## Evidence still needed

This is a design note. The draft does not establish an implemented model, user-feedback results, performance measurements, or verified tax calculations. Those need to be documented before publishing a case study.

For now, the priority is a transparent calculation model and a small set of checked scenarios. Monetization can wait.
