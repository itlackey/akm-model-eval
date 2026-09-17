---
tags: [release, rollback]
---

When candidate validation fails, restore the `worker-stable` image, validate a
canary against the restored image, and require three consecutive green health
checks before resuming publishers.
