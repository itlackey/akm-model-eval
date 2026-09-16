---
description: Ordered recovery procedure for a stalled Relay worker queue.
tags: [queue, recovery, checkpoint]
---

# Recovering a Stalled Worker Queue

Use this procedure when jobs remain queued while the Worker Service reports no
forward progress. The procedure protects the queue checkpoint from referring to
artifact names that were never made durable.

## Confirm the failure

Confirm that queue depth is above 500 jobs for five minutes and that the Metrics
Collector reports no completed jobs during the same window. Record the current
checkpoint offset before changing anything.

## Recover in order

1. Pause publishers before replacing the worker image.
2. Drain in-flight work and wait until active worker count reaches zero.
3. Replace the worker image.
4. Rename both the artifact manifest and the artifact blob into their final
   names.
5. Commit the queue checkpoint only after both renames succeed.
6. Run the health check until it reports green three consecutive times.
7. Resume publishers only after the third green health check.

The order is an invariant. Committing the checkpoint before both renames can
lose the only retry reference for an artifact.

## Roll back

If either rename fails, leave the checkpoint at its prior offset, restore the
previous worker image, and keep publishers paused. If a health check fails,
restore the previous worker image before resuming publishers. Never advance the
checkpoint merely because the replacement image started successfully.

## What not to preserve

An early draft suggested waiting a fixed two minutes after deployment. That
timer was removed because it did not prove the worker was healthy. The current
rule is three consecutive green health checks, regardless of elapsed time.
