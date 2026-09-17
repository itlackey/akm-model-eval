---
description: Release batch-job backpressure only after the queue remains below the recovery threshold.
when_to_use: Use this when batch intake is throttled because the Redis queue is saturated.
---

Keep interactive jobs available on their separate priority queue. Return HTTP
429 with a 30-second `Retry-After` for new batch jobs while Redis queue depth is
800 or higher. Let the Metrics Collector remove backpressure only after depth
stays below 300 for ten consecutive minutes; operators must not clear it by
hand.
