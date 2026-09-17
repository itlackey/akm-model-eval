---
description: Detailed observation from repeated queue checkpoint recovery attempts.
updated: 2026-03-02
---

During a staged Worker Service recovery, publishers were paused and checkpoint
offset 4182 was recorded before any artifact changes. The artifact manifest
rename succeeded on the first attempt, but the artifact blob rename failed.
The checkpoint remained at its prior offset, which allowed the same job to be
retried without losing its position or claiming completion prematurely.

The previous Worker Service image was restored through `worker-stable`. The
operator retried both renames rather than retrying only the failed blob, because
the pair is treated as one recovery operation. The checkpoint was committed
only after both the manifest and blob renames succeeded in the same attempt.

Validation then checked the artifact in the Object Store, matching completion
state in PostgreSQL, and three consecutive completed health samples. Publishers
remained paused throughout. A timed-out health sample reset the consecutive
count. The durable lesson is the ordering rule, not the particular offset: keep
the prior checkpoint until both renames succeed, then validate durable records
and health before resuming publishers.

This observation does not authorize manual checkpoint editing, does not make a
manifest-only success sufficient, and does not change the interactive queue.
It applies when recovery must remain retryable after a partial artifact rename.

