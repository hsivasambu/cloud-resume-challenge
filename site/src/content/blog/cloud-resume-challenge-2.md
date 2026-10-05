---
title: "Part 1: Hosting the Portfolio on AWS"
description: "How I published the portfolio with S3, CloudFront, DNS, and automated cache invalidation."
date: 2025-08-13
tags: ["cloud", "aws", "infra"]
draft: false
---

The first version of my resume site was a folder of HTML, CSS, and JavaScript. Publishing it meant working through three separate concerns: storing the files, serving them over HTTPS, and connecting my domain.

## Hosting with S3

I uploaded the static assets to Amazon S3. The important question was access: which requests should be allowed to retrieve those objects?

For the blog, the Terraform configuration blocks public bucket access and uses CloudFront Origin Access Control. The bucket policy permits the distribution to read the files. That keeps the origin behind the public delivery layer.

## Delivery with CloudFront

CloudFront serves the site through a CDN and caches content according to the distribution's settings. A request can be answered from cache; otherwise, CloudFront retrieves the object from S3.

Caching also explains why a successful upload does not always produce an immediate visible change. I added cache invalidation to the deployment workflow so updates can reach readers after the files are synced.

## Connecting the domain

DNS connects the domain to the distribution. It is separate from storage and caching: a correct DNS record does not guarantee that the distribution can read its origin, or that it is serving the latest file.

![Website delivery architecture](/images/cloud-resume-challenge/content-delivery-flowchart.svg)

DNS resolves the address; the browser then requests the site from CloudFront. Route 53 is not a proxy carrying the page content.

## What I took from this stage

The useful lesson was learning to troubleshoot the layers separately. When a page did not behave as expected, I could check domain resolution, distribution configuration, origin access, and cache state rather than changing several settings at once.

The current [blog infrastructure](https://github.com/hsivasambu/cloud-resume-challenge/blob/main/infra/modules/blog_site/main.tf) and [deployment workflow](https://github.com/hsivasambu/cloud-resume-challenge/blob/main/.github/workflows/frontend-deploy.yml) capture those decisions in code.

[Next: building the visitor counter](/blog/cloud-resume-challenge-3)
