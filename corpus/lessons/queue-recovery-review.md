---
description: Preserve the checkpoint until artifact recovery appears complete.
when_to_use: Use this during a stalled queue recovery involving artifact renames.
---

Pause publishers and avoid advancing the checkpoint after only the manifest
rename succeeds. Confirm the blob rename before continuing. Restore the prior
worker image when recovery remains uncertain.
