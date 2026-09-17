---
description: Public synthetic session containing a durable backpressure lesson.
---

# Backpressure Incident Session

[user @ 2026-02-24T16:00:00Z] Batch intake resumed too early and the queue saturated again. Find out why.

[assistant @ 2026-02-24T16:04:00Z] An operator manually cleared backpressure as soon as queue depth crossed below 300. It had remained below 300 for only forty seconds.

[assistant @ 2026-02-24T16:08:00Z] We restored the flag. The Metrics Collector removed it after queue depth stayed below 300 for ten consecutive minutes, and batch intake then remained stable.

[user @ 2026-02-24T16:10:00Z] Preserve the lesson: crossing the threshold once is insufficient, and operators must not bypass the sustained recovery window.
