---
description: Current release procedure for the Relay Worker Service.
tags: [release, worker, rollback]
---

# Worker Service Release Procedure

The Operations Team approves every production release. After approval, pause
publishers and wait for active worker count to reach zero. The Release
Controller may then deploy the candidate Worker Service image.

Send one canary job through the API Gateway. The release succeeds only when the
canary artifact exists in the Object Store and PostgreSQL records the matching
completion state. Run the health check until it reports green three consecutive
times, then resume publishers.

If canary validation or a health check fails, keep publishers paused. The
previous Worker Service image remains available under the `worker-stable`
alias. Publishers must not resume while a failed candidate is active.

## Rollback note

Restore the `worker-stable` alias before resuming publishers. Verify one canary
against the restored image and require three consecutive green health checks.
