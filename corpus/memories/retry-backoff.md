---
description: Retry schedule for transient artifact reads.
updated: 2026-01-21
---

The Worker Service retries transient Object Store reads after one, four, and
sixteen seconds. A signature failure is permanent and is never retried.
