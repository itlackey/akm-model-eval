---
description: Partially improved Relay Worker Service release procedure.
tags: [release, worker]
---

# Worker Service Release

Pause publishers and wait for active worker count to reach zero. Deploy the
candidate Worker Service image, validate one Object Store canary artifact, and
require three consecutive green health checks before resuming publishers.

If validation fails, restore `worker-stable` before resuming. The procedure does
not yet say to verify matching PostgreSQL completion state or repeat canary and
health validation after rollback.
