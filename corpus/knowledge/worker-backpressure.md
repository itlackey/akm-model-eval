# Worker Backpressure

The API Gateway stops accepting new batch jobs when Redis queue depth reaches
800. It returns HTTP 429 with a `Retry-After` value of 30 seconds. Interactive
jobs remain enabled because they use a separate priority queue.

The Worker Service removes backpressure only after queue depth falls below 300
for ten consecutive minutes. Operators must not clear the backpressure flag by
hand; the Metrics Collector owns that transition.
