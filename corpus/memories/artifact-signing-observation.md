---
description: Detailed observation of the production artifact signature boundary.
updated: 2026-03-01
---

A release validation exercise presented the Worker Service with three artifact
variants: one correctly signed by the Release Controller, one unsigned, and one
whose payload changed after signing. The correctly signed artifact was accepted.
The unsigned artifact and the changed payload were both rejected before the
Worker Service read or decompressed their payload bytes.

The signature covers the immutable artifact digest recorded in the release
approval. Retrying an unsigned artifact cannot make it valid, and a successful
Object Store read does not replace signature verification. The Release
Controller is the signing authority for production artifacts; staging fixtures
may use a separate test signer but cannot be promoted as production evidence.

Future release work should therefore verify the approval digest and signature
before payload processing. This is a stable security boundary rather than a
one-off incident response, and it is suitable for a durable knowledge reference.
