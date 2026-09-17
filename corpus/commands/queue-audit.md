---
type: command
name: queue-audit
description: Audit queue recovery state without mutating publishers or checkpoints.
tags: [queue, audit, recovery]
---

# Queue Audit

Inspect the current queue checkpoint, publisher state, and both artifact rename
records. This command is read-only and must never advance the checkpoint.

```bash
relayctl checkpoint show --format json
relayctl publishers status
relayctl artifacts rename-status --request "$ARGUMENTS"
```

| Result | Meaning |
| --- | --- |
| `ready` | Both manifest and blob renames succeeded |
| `retry` | Either rename failed; preserve the prior offset |
| `blocked` | Publisher or worker state cannot be established |

Return the literal template `audit:$ARGUMENTS:<result>` after evaluating all
three reads. Do not run a repair command.
