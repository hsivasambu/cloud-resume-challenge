---
title: "Cloud Resume Challenge: Index = 0 "
description: "Starting the Cloud Resume Challenge"
date: 2025-08-03
tags: ["cloud", "aws", "infra"]
draft: false
---

Over the past decade, I have watched the tech industry steadily shift toward cloud computing, moving from self-managed, on-premises infrastructure to vendor-managed platforms and service-based architectures. Traditional models built around perpetual licenses, dedicated hardware, and large internal operations teams gradually gave way to subscription-based services, shared responsibility models, and smaller teams focused on orchestration rather than ownership. Infrastructure didn’t disappear, but it became increasingly abstracted. What once required hands-on configuration now lives behind APIs, managed services, and billing dashboards that can obscure both operational complexity and true cost if you are not intentional about understanding them.

## Cloud Computing: Fewer Servers, More Questions

After that shift became clear, the <a href="https://cloudresumechallenge.dev/" target="_blank" rel="noopener noreferrer"><strong>Cloud Resume Challenge</strong></a> stood out as a practical way to deepen my understanding of how modern cloud systems are actually built and operated. Rather than focusing on isolated services, it forces you to think in terms of end-to-end architecture: frontend delivery, backend logic, automation, security boundaries, and operational reliability. It is less about checking boxes and more about understanding how the pieces interact under real constraints.

The challenge turned out to be more demanding than I expected. I restarted parts of the project more than once as my understanding evolved. The AWS console alone can be overwhelming, not because it is poorly designed, but because of the sheer density of capability it exposes. Early on, the number of services, configuration options, and implicit dependencies slowed momentum and forced me to step back and rethink how I approached the build.

Once I successfully deployed a static site to S3 and connected it through CloudFront, the system began to feel tangible. From there, concepts like caching behavior, DNS resolution, and request flow became much easier to reason about. Each layer added clarity rather than confusion, and the architecture gradually shifted from a collection of services into a cohesive system.

From that point forward, the project expanded into areas that more closely resemble production environments. I introduced infrastructure as code to make deployments repeatable, implemented CI/CD pipelines to remove manual steps, and added backend services to handle dynamic functionality. Along the way, I had to confront issues around permissions, cross-origin policies, environment separation, and failure modes. These were not theoretical problems; they were the same challenges that surface in real systems when assumptions meet reality.

This series documents that process in detail. It focuses less on polished outcomes and more on the reasoning behind design decisions, the mistakes that led to better architecture, and the tradeoffs that are unavoidable when building systems meant to scale and evolve. The goal is not to present a perfect solution, but an honest one. The end result of the Cloud Resume Challenge was this blog, a static site with infrastructure managed through code with a CI/CD pipeline via GitHub Actions!

## Series

- [Part 1: From Local Files to Global Access](/blog/cloud-resume-challenge-2)
- More parts coming soon.

![Cloud Computing](/images/cloud-resume-challenge/cloud-computing.jpg)
