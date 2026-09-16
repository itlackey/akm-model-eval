---
name: release-operator
description: Safely deploy the Relay Worker Service.
---

# Release Operator

Pause publishers and wait for active worker count to reach zero. Deploy the
candidate Worker Service image, validate one canary artifact in the Object
Store, confirm matching completion state in PostgreSQL, and require three
consecutive green health checks before resuming publishers.

If validation fails, keep publishers paused. The previous image is available
through the `worker-stable` alias. Restore that alias before resuming.
