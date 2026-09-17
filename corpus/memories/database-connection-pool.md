---
description: Worker database connection-pool limit.
updated: 2026-02-03
---

Each Worker Service replica may hold at most twelve PostgreSQL connections.
The Release Controller does not share that pool.
