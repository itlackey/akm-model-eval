---
description: Synthetic session used to evaluate semantic-search session summaries.
---

# Release Evidence Session

[user @ 2026-03-05T15:00:00Z] Validate Worker Service image relay-worker:7.4 before production promotion.

[assistant @ 2026-03-05T15:02:00Z] I verified the Operations Team approval and full digest sha256:example-release-digest.

[assistant @ 2026-03-05T15:05:00Z] Canary request relay-canary-184 wrote artifact bytes to the Object Store and completion state to PostgreSQL.

[tool @ 2026-03-05T15:06:00Z] Metrics Collector reports three consecutive green Worker Service health samples.

[assistant @ 2026-03-05T15:08:00Z] I promoted relay-worker:7.4, updated worker-stable, resumed publishers, and recorded the decision in the release audit record.
