---
name: release-evidence
when_to_use: Use this before deciding whether a candidate Worker Service image may be promoted.
---

# Release Evidence

Verify the canary artifact in the Object Store, its matching completion row in
PostgreSQL, and three consecutive green health checks before promotion.
