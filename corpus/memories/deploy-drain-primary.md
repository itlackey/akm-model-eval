---
description: Safe worker deployment ordering.
updated: 2026-02-20
---

Pause publishers, drain active workers to zero, replace the worker image, and
resume publishers only after three consecutive green health checks.
