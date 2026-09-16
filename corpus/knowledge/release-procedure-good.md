---
description: Revised Relay Worker Service release and rollback procedure.
tags: [release, worker, rollback]
---

# Worker Service Release and Rollback

The Operations Team approves every production release. Pause publishers and
wait for active worker count to reach zero before the Release Controller deploys
the candidate Worker Service image.

Validate one canary job. Its artifact must exist in the Object Store and its
matching completion state must exist in PostgreSQL. Require three consecutive
green health checks before resuming publishers.

If either canary validation or a health check fails, keep publishers paused,
restore the previous Worker Service image through the `worker-stable` alias,
validate one canary against the restored image, and require three consecutive
green health checks. Resume publishers only after those rollback checks pass.
