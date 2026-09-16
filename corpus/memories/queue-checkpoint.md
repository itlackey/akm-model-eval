---
description: Queue checkpoint durability invariant observed during recovery.
updated: 2026-02-14
---

On 2026-02-14, the recovery test confirmed that the queue checkpoint may be
committed only after both the artifact manifest rename and artifact blob rename
succeed. Any rename failure must leave the checkpoint at its prior offset so
the job can be retried. This applies to the Worker Service recovery path.
