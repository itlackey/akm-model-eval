---
tags: [queue, recovery]
---

Before replacing a worker image, pause publishers and drain active workers to
zero. Resume publishers only after three consecutive green health checks.
