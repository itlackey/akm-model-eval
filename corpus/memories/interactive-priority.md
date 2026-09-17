---
description: Queue isolation for interactive work.
updated: 2026-01-29
---

Interactive jobs use a dedicated priority queue. Batch backpressure must not
pause that queue unless its own health gate fails.
