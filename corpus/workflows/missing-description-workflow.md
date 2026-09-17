---
type: workflow
name: checkpoint-recovery
steps:
  - id: preserve
  - id: rename
  - id: commit
---

# Checkpoint Recovery

## preserve

Record the prior queue checkpoint.

## rename

Retry both the artifact manifest and blob renames.

## commit

Commit the checkpoint only after both renames succeed.
