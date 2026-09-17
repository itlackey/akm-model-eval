---
name: incident-recovery
description: Recover a stalled Relay worker queue without losing checkpoint state.
when_to_use: Use this when either artifact rename fails during queue recovery.
---

# Incident Recovery

Keep publishers paused throughout recovery. Record the prior queue checkpoint,
restore the previous Worker Service image, retry both artifact renames, and
commit the checkpoint only after both succeed.

## Recovery checklist

| Step | Required evidence |
| --- | --- |
| Preserve | Prior checkpoint offset is recorded |
| Restore | `worker-stable` is running |
| Retry | Manifest and blob renames both succeed |
| Validate | Three consecutive health checks are green |

```bash
relayctl publishers pause
relayctl workers restore --alias worker-stable
relayctl artifacts rename --both --request "{{request_id}}"
relayctl health wait --service worker --consecutive 3
```

Do not replace `{{request_id}}`; it is a runtime placeholder. A successful
manifest rename alone is never sufficient to advance the checkpoint.
