---
tags: [backpressure, queue]
---

When Redis queue depth reaches 800, reject new batch jobs with HTTP 429 while
interactive jobs continue separately. Remove backpressure only after depth
stays below 300 for ten consecutive minutes.
