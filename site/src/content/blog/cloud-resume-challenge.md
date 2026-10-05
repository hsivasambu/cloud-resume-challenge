---
title: "AWS Portfolio Infrastructure & CI/CD"
description: "An AWS-hosted portfolio with a serverless visitor counter, Terraform-managed infrastructure, and automated GitHub Actions deployments."
date: 2025-08-03
tags: ["cloud", "aws", "infra"]
draft: false
---

## Project at a glance

- **Problem:** Publish a portfolio with repeatable infrastructure and deployments rather than manual console changes.
- **My role:** Built and operated this personal AWS portfolio, including its frontend, serverless backend, infrastructure configuration, and deployment workflows.
- **Key tradeoff:** Used static hosting and managed services to keep operational overhead low while learning the full request and deployment path.
- **Delivered:** S3 and CloudFront hosting, an API Gateway/Lambda/DynamoDB visitor counter, Terraform infrastructure, and GitHub Actions pipelines.
- **Validation:** Imported existing resources into Terraform and checked for zero drift; backend tests run in the deployment pipeline.
- **Status and limitations:** Live personal site. The counter measures successful page-load requests, not unique visitors.

[View the live resume](https://harry-sivasambu.com/) · [Explore the repository](https://github.com/hsivasambu/cloud-resume-challenge)

## Delivery approach

I started with a static site on S3 and CloudFront, then added a visitor counter and deployment automation. Building the request path in stages made caching, DNS, cross-origin policies, and permissions easier to reason about.

As the site evolved, I introduced Terraform to make infrastructure changes repeatable and GitHub Actions to automate frontend and backend deployments. Importing the existing AWS resources required reconciling the running infrastructure with its configuration before checking for drift.

The main lesson was that a working page is only one part of delivery. Permissions, infrastructure state, backend behavior, and cache invalidation all affect whether a change reaches users reliably. The articles below document the implementation and the decisions behind it.

## Series

- [Part 1: Hosting the Portfolio on AWS](/blog/cloud-resume-challenge-2)
- [Part 2: Building the Serverless Visitor Counter](/blog/cloud-resume-challenge-3)


![Cloud Computing](/images/cloud-resume-challenge/cloud-computing.jpg)
