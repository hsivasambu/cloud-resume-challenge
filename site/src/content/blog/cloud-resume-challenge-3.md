---
title: "Part 2: Building the Serverless Visitor Counter"
description: "Building an atomic DynamoDB counter, understanding its API behavior, and defining what the count actually measures."
date: 2025-08-20
tags: ["cloud", "aws", "serverless", "architecture"]
draft: false
---

The visitor counter was my first dynamic feature on this site. It needed to save one number, update it when the resume loaded, and return the new value to the browser.

## The request path

1. The browser loads the static resume through CloudFront.
2. Its JavaScript calls `GET /count` on API Gateway.
3. Lambda increments an item in DynamoDB.
4. The API returns the updated `visits` value as JSON.

![Serverless counter architecture](/images/cloud-resume-challenge/serverless-backend-flowchart.svg)

The current endpoint increments on GET; it does not expose separate read and write operations. That was sufficient for the challenge, although a POST for increments and a read-only GET would be a clearer API contract.

## Updating the count safely

A read-modify-write sequence can lose increments when two requests read the same starting value. The Lambda uses DynamoDB's atomic `ADD` operation instead:

```python
resp = table.update_item(
    Key={"id": "site"},
    UpdateExpression="ADD visits :inc",
    ExpressionAttributeValues={":inc": 1},
    ReturnValues="UPDATED_NEW",
)
```

This protects the increment itself from that race. It does not deduplicate retries or repeated page loads.

## Why managed services

Lambda, API Gateway, and DynamoDB fit a small backend without requiring me to run a server. The tradeoff is having to understand permissions, request behavior, and service configuration across several components.

API Gateway's CORS configuration allows the resume origin. CORS controls browser access to responses; it is not authentication and does not prevent direct API calls.

## What the number means

The counter records successful increments, not unique visitors. Refreshes, repeat visits, automated requests, and direct calls can all increase it. It is a learning feature rather than a reliable recruiting or audience metric.

If the request fails, the resume displays `n/a` and the page remains usable. The counter should not block someone from reading my experience.

![Visitor counter on the resume](/images/cloud-resume-challenge/visitor_counter.jpg)

The [Lambda implementation](https://github.com/hsivasambu/cloud-resume-challenge/blob/main/backend/app.py), [backend tests](https://github.com/hsivasambu/cloud-resume-challenge/blob/main/backend/tests/test_app.py), and [API configuration](https://github.com/hsivasambu/cloud-resume-challenge/blob/main/infra/modules/counter_api/main.tf) show the current behavior.

[Previous: hosting the portfolio](/blog/cloud-resume-challenge-2) · [Next: making the portfolio repeatable](/blog/cloud-resume-challenge-4)

[Back to the project overview](/blog/cloud-resume-challenge)
