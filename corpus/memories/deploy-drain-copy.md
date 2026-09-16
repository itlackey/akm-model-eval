---
description: Duplicate note about safe worker deployment ordering.
updated: 2026-02-18
---

Before replacing the worker image, pause publishers and drain active workers to
zero. Resume publishers only after the health check reports green three times
in succession.
