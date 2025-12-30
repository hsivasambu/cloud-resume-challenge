---
title: "Part 1: From Local Files to Global Access "
description: "Starting the Cloud Resume Challenge"
date: 2025-08-13
tags: ["cloud", "aws", "infra"]
draft: false
---

Every cloud journey starts somewhere unglamorous. For me, it started with a folder of static files sitting on my local machine. HTML, CSS, a bit of JavaScript. Nothing dynamic. Nothing impressive. Just something that worked when opened in a browser.

But “working locally” and “accessible globally” are two very different problems.

This stage of the Cloud Resume Challenge forced me to confront that gap. Hosting a static website sounds trivial on the surface, but the moment you move beyond localhost, you start interacting with the foundational layers of the modern internet: object storage, DNS, caching, and global content delivery.

---

### Is this just Google Drive with extra steps?

The first real step was pushing static assets into Amazon S3. On paper, this is straightforward. In practice, it immediately introduces questions that don’t exist in local development (or when you upload files to Google Drive):

- How should access be controlled?
- Should objects be publicly readable?
- What happens when files change?
- How does this scale globally?

S3 is deceptively powerful. It looks like storage, but it behaves more like a distributed system. Understanding bucket policies, object permissions, and public access controls became necessary very quickly. The moment the site became reachable from the internet, security stopped being theoretical.

---

### Making It Global with CloudFront

Hosting files wasn’t enough. I wanted fast, consistent access regardless of where users were located. That’s where CloudFront entered the picture.

Connecting S3 to a CloudFront distribution introduced a new layer of complexity and clarity at the same time. Suddenly, I had to think about:

- Cache behavior and invalidations
- Origin access and security boundaries
- What “edge locations” actually do
- Why content sometimes didn’t update when expected

This was one of the first moments where cloud abstractions started to click. CloudFront wasn’t just a performance booster. It was a control plane for how content flows across the internet.

Seeing requests hit edge locations instead of a single origin shifted my understanding of scale. The architecture stopped being theoretical and started behaving like something real users could depend on.

### What CloudFront Does

Amazon CloudFront is a global content delivery network (CDN) that sits between users and your origin (such as an S3 bucket or an API). Its primary role is to deliver content faster, more reliably, and more securely by caching copies of your content at edge locations around the world.

When a user requests a resource, CloudFront serves it from the nearest edge location if it is already cached. If not, it retrieves the content from the origin, returns it to the user, and stores a copy for subsequent requests. This reduces latency, lowers load on the origin, and improves overall performance.

Beyond performance, CloudFront also provides control and protection. It allows you to define cache behavior, enforce HTTPS, restrict access to origins, integrate with AWS WAF, and control how requests and responses are handled at the edge. In practice, CloudFront becomes the public entry point for your application, shaping how traffic flows before it ever reaches your backend.

---

### DNS: The Quiet Backbone

DNS is easy to overlook until it breaks. Configuring Route 53 forced me to think about how domain names, records, and routing actually work together.

It also reinforced an important idea: most systems don’t fail because of one big mistake. They fail because of small assumptions stacked on top of each other. A missing record, an incorrect alias, or a misaligned TTL can quietly take everything offline.

At this stage, the project crossed an important threshold. It wasn’t just “a website” anymore. It was a distributed system, even if a simple one.

<img
  src="/images/cloud-resume-challenge/Flowchart-CDN.png"
  alt="Content delivery flowchart showing DNS to CloudFront and S3"
  style="display: block; max-width: 100%; height: auto; margin: 16px auto;"
/>

---

### When Things Finally Made Sense

There was a clear moment when everything clicked. After wiring together S3, CloudFront, and Route 53, I could type a URL into a browser and understand every step of what was happening behind the scenes. The request path, the caching behavior, and the delivery flow all made sense.

That clarity changed how I approached the rest of the challenge. Instead of following instructions, I started reasoning through architecture. Instead of guessing, I could predict outcomes.

This stage laid the foundation for everything that followed. Without it, concepts like CI/CD, serverless backends, and security controls would have felt abstract. With it, they became logical extensions of an already functioning system.

---
