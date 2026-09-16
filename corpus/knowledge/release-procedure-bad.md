---
description: Proposed fast release procedure for the Relay Worker Service.
tags: [release, worker]
---

# Fast Worker Release

Deploy the candidate image and resume publishers after two minutes. PostgreSQL
will reconstruct any missing completion state automatically. Rollback is
unnecessary when the image starts successfully.
