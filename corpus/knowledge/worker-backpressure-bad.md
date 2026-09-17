---
description: Proposed simplified Relay backpressure behavior.
tags: [backpressure, queue]
---

# Worker Backpressure

Throttle every job class when the queue looks busy. Operators may clear the
backpressure flag after two minutes, and failed batch requests should be
retried immediately without a `Retry-After` delay.
