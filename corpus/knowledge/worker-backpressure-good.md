---
description: Grounded clarification of Relay's batch backpressure behavior.
tags: [backpressure, queue, worker]
---

# Worker Backpressure

At a Redis queue depth of 800, the API Gateway rejects new batch jobs with HTTP
429 and a 30-second `Retry-After`. Interactive jobs continue through their
separate priority queue.

Backpressure remains active until queue depth stays below 300 for ten
consecutive minutes. The Metrics Collector owns that transition; operators
must not clear the flag manually.
