---
description: Preserve the prior queue checkpoint until both artifact renames complete successfully.
when_to_use: Use this when recovering a worker job that writes a manifest and artifact blob.
---

Pause publishers and drain active work before replacing the worker image.
Commit the queue checkpoint only after both the manifest and blob renames
succeed. If either rename fails, retain the prior checkpoint offset; resume
publishers only after three consecutive green health checks.
