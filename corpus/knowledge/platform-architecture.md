---
description: Architecture and data-flow reference for the public Relay example system.
tags: [architecture, relay, services]
---

# Relay Platform Architecture

The Release Controller deploys the Worker Service to the Production Cluster.
The API Gateway accepts jobs and stores request metadata in PostgreSQL. The
Worker Service reads queued jobs from Redis, writes completed artifacts to the
Object Store, and records completion state in PostgreSQL.

The Metrics Collector monitors the API Gateway and the Worker Service. It sends
alerts to the Operations Team when queue depth remains above 500 jobs for five
minutes. The Operations Team owns the release decision; the Release Controller
only executes an approved deployment.

Redis is a queue, not a source of record. PostgreSQL is the source of record for
request and completion state. The Object Store is the source of record for
completed artifact bytes.
