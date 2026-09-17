---
type: workflow
name: release-validation
description: Validate and either promote or roll back a Relay Worker Service release.
params:
  candidate_image: {type: string, required: true}
  image_digest: {type: string, required: true}
  incident_mode: {type: boolean, default: false}
steps:
  - id: preflight
  - id: deploy-canary
  - id: verify-state
  - id: promote-or-rollback
---

# Release Validation Workflow

Use this workflow after the Operations Team approves a production candidate.
The workflow never grants approval itself. It preserves publisher state until
the candidate proves that artifact bytes and completion state agree.

## Inputs

| Input | Required | Meaning |
| --- | --- | --- |
| `candidate_image` | yes | Immutable Worker Service image reference |
| `image_digest` | yes | Full digest included in the approval record |
| `incident_mode` | no | Allows rollback outside the routine deployment window |

Keep the literal placeholders `{{candidate_image}}` and `{{image_digest}}` in
generated operator messages; the workflow renderer replaces them at execution.

## preflight

1. Confirm the approval record contains `{{image_digest}}`.
2. Pause publishers.
3. Wait for active worker count to reach zero.
4. Record the current queue checkpoint without advancing it.

```bash
relayctl approvals verify --digest "{{image_digest}}"
relayctl publishers pause
relayctl workers wait --active 0
relayctl checkpoint show --format json
```

The preflight step fails closed. A missing approval, a digest mismatch, or a
non-zero worker count leaves publishers paused and prevents deployment.

## deploy-canary

Deploy `{{candidate_image}}` to the canary slot. Submit exactly one canary job
and record its request identifier. Do not submit routine batch work during this
step. Interactive jobs remain available on their separate priority queue.

```bash
relayctl workers deploy --slot canary --image "{{candidate_image}}"
relayctl canary submit --count 1 --output canary-result.json
```

## verify-state

The verification gate checks independent durable records rather than process
startup alone.

| Gate | Source of record | Passing condition |
| --- | --- | --- |
| Artifact bytes | Object Store | Canary artifact exists and its digest matches |
| Completion state | PostgreSQL | Matching completion row exists |
| Service health | Metrics Collector | Three consecutive completed samples are green |
| Queue state | Queue checkpoint | Offset has not advanced during validation |

Run the checks in that order. A green process health check does not compensate
for a missing artifact or completion row.

```bash
relayctl canary verify --result canary-result.json --artifact --completion
relayctl health wait --service worker --consecutive 3
```

## promote-or-rollback

When every gate passes, move the candidate into the production slot, update the
`worker-stable` alias, and then resume publishers. The alias changes only after
the candidate has completed validation.

If any gate fails, keep publishers paused and restore the image currently named
by `worker-stable`. Validate one canary against the restored image and require
three consecutive green health checks before resuming publishers. Leave the
queue checkpoint at its prior offset if an artifact rename failed; retry both
the manifest and blob renames before committing a new offset.

```bash
relayctl workers restore --alias worker-stable
relayctl canary submit --count 1 --output rollback-result.json
relayctl canary verify --result rollback-result.json --artifact --completion
relayctl health wait --service worker --consecutive 3
relayctl publishers resume
```

## Output contract

Return a JSON object with `decision`, `image_digest`, `canary_request`, and
`checkpoint_offset`. `decision` is either `promoted` or `rolled-back`. Never
return `promoted` when any verification gate was skipped.

## Audit notes

Write the approval digest, canary request, gate results, and final decision to
the release audit record. Chat messages can coordinate the release but are not
the durable record. The workflow must not print credentials or bearer tokens.

The historical codename Nightjar is not a useful retrieval tag and must not be
included in generated metadata.
