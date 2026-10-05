---
title: "Part 3: Making the Portfolio Repeatable"
description: "Wrapping up the AWS challenge with Terraform, remote state, and GitHub Actions deployments."
date: 2026-10-04
tags: ["cloud", "aws", "infra", "ci/cd"]
draft: false
---

By the end of [Part 1](/blog/cloud-resume-challenge-2) and [Part 2](/blog/cloud-resume-challenge-3), the site was online and the counter worked. The remaining question was how to keep making changes without repeating the same console and upload steps.

## Bringing the infrastructure into Terraform

I had already created AWS resources, so adopting Terraform meant importing them rather than starting over. I then reconciled the configuration with the running environment and checked the plan for unintended changes.

Getting to a plan with no changes gave me a baseline. It was a check at that point in time, not a promise that the infrastructure could never drift.

The [production configuration](https://github.com/hsivasambu/cloud-resume-challenge/blob/main/infra/envs/prod/main.tf) connects separate modules for the resume, blog, and counter API. That organization makes it easier to find the configuration behind a particular part of the site.

## Keeping state outside my laptop

Terraform needs state to associate its configuration with real resources. I configured an S3 backend with encryption and a DynamoDB lock table, so the state is stored remotely and concurrent operations can be locked.

That state has a different job from the website bucket or visitor-count table. One tracks infrastructure; the others hold the content and application data.

## Deploying changes from Git

The deployment workflows run on relevant changes pushed to `main`:

- **Resume:** Sync the HTML, CSS, and JavaScript to S3, then request a CloudFront cache invalidation.
- **Blog:** Install dependencies, build the Astro site, sync the generated files to S3, and request an invalidation.
- **Backend:** Run the Python tests, package the Lambda code and dependencies, then update the function.

The frontend workflow checks which paths changed, so a blog edit does not also redeploy the resume. The backend workflow stops before deployment if its tests fail.

Cache invalidation still takes time to propagate. A completed upload and the page a reader sees are two different checkpoints, which is why I also check the published site.

The [frontend and blog workflow](https://github.com/hsivasambu/cloud-resume-challenge/blob/main/.github/workflows/frontend-deploy.yml) and [backend workflow](https://github.com/hsivasambu/cloud-resume-challenge/blob/main/.github/workflows/backend-deploy.yml) show those steps.

## Keeping infrastructure changes separate

These workflows deploy application files; they do not run `terraform apply`. Infrastructure changes remain a separate plan-and-apply step. That lets me inspect resource changes before applying them, while ordinary writing and styling updates follow the automated deployment path.

## Wrapping up the challenge

The finished project connects static hosting, a serverless counter, infrastructure configuration, and deployment automation. Each stage addressed a different question: can readers reach the site, does the backend behave as intended, and can I publish the next change consistently?

For me, the most useful part was following those dependencies all the way through. A change is only finished when the intended behavior reaches the reader. That is the same delivery habit I bring to project work: define the outcome, check the handoffs, and verify the result.

[Previous: building the visitor counter](/blog/cloud-resume-challenge-3) · [Back to the project overview](/blog/cloud-resume-challenge)
