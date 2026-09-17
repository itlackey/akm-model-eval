---
type: fact
name: release-invariants
description: Stable sources of record and safety boundaries for Relay releases.
category: convention
---

# Relay Release Invariants

PostgreSQL is the source of record for request and completion state. The Object
Store is the source of record for artifact bytes. Redis is a queue, not a source
of record. Operations approves releases; the Release Controller deploys them.
