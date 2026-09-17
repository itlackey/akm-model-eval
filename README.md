# AKM Model Eval

A frozen public corpus and one standard-library Python script for comparing
models on the work AKM asks an endpoint to perform. This is a model capability
benchmark. It does not measure whether AKM itself improves an agent; `akm-eval`
owns that job.

The suite has three workload tiers and four separately reported tracks:

- `compact / focused` contains 52 focused cases, four for each of 13
  model-backed tasks. Its synthetic assets describe one fictional system and
  expose precise facts that deterministic checks can verify.
- `deep / legacy` contains 39 cases. Its core is the bakeoff's original
  24-item workload: 12 consolidations and 12 distillations built from 49 static
  source documents.
  Client/project names, user and session identifiers, internal paths, dates, and
  the original item IDs were replaced with stable generic aliases. Document
  count, ordering, structure, numeric constraints, and overlap between versions
  were retained.
- The other 15 legacy deep cases add work the original bakeoff did not cover: four
  long-document graph extractions, four grounded revisions, four proposal-quality
  judgments, and three multi-document syntheses. They use 15 exact documents
  copied from the public AKM revisions named in their corpus paths. The largest
  case contains 118,767 source characters.
- `deep / production` contains 29 cases shaped like current AKM calls: 20–35
  memory consolidation pools, memory distillation and review-band quality
  judgments, ordered graph batches and 1,600-character chunk calls, revisions
  of real asset shapes, complex session extraction and summaries, existing-
  metadata enhancement, and schema repair across six asset types.
- `context / context` contains three otherwise identical extraction tasks at
  approximately 35.7K, 47.7K, and 65.8K prompt tokens. This keeps endpoint
  context qualification separate from compact accuracy and deep task scores.

The anonymized fixtures preserve the original workload, not byte identity, so
new scores are not numerically interchangeable with results from the private
bakeoff corpus. There is deliberately no mapping back to its private IDs.
Everything needed to run is checked in across 141 corpus files: there is no
corpus generator, downloader, package install, separate case file, or model
judge.

## Coverage

The process inventory was checked against the live model-feature call sites in
`itlackey/akm` commit `7c50f57c8e2da101f2b9226e5fbaa7d9c7cab0e5`.
The suite covers all 12 bounded chat-completion feature keys with real call
sites at that revision, plus the active proposal-triage judgment call:

- memory consolidation;
- knowledge and lesson distillation;
- memory inference;
- graph extraction;
- metadata enhancement;
- lesson quality judgment;
- proposal quality judgment;
- memory contradiction detection;
- session extraction;
- reflection proposals;
- `remember` enrichment;
- schema repair;
- proposal triage (`accept`, `reject`, or `defer` using the live asset and
  sibling proposals).

Session extraction also includes the separate session-summary call under the
same process row.

Curate reranking is deliberately excluded. It uses a dedicated cross-encoder,
a different request protocol, and a different model; it does not measure a chat
model's ability to perform AKM work.

Run the coverage inventory at any time:

```sh
python3 bench.py list
```

The compact tier supplies process breadth and precise regression checks. The
legacy deep track preserves historical comparability. The production deep track
tests current AKM request shapes, including preservation and false-positive
behavior. The context tier qualifies endpoint limits independently. Deep work
includes reconciling overlapping knowledge, preserving constraints during
distillation, extracting a graph from a substantial document, revising without
inventing facts, judging a large proposed change, and synthesizing several
sources. Short schema and classification calls are not padded to look long.

## Verify

Verification is offline. It checks the exact corpus inventory, all 49 anonymized
bakeoff documents, complete process coverage, case IDs and tracks, context-size
bands, every process-specific scorer against a known-good response, rejection
of empty responses, exact-quote grounding failures, deliberately injected false
positives and preservation losses, and publication-safety markers.

```sh
python3 bench.py verify
```

## Run chat cases

`run` appends one JSON object per attempt and resumes successful case-and-label
pairs. Transient transport failures and HTTP 408, 425, 429, 500, 502, 503, and
504 responses are retried five times with exponential backoff by default. A
failed case remains in the JSONL evidence but is attempted again on resume;
scoring uses its latest attempt, so recovery neither erases the outage nor
double-counts the case. Supply a distinct label for each model or server configuration. Results
include the suite fingerprint; the runner and scorer reject results from a
different corpus or case revision.

```sh
python3 bench.py run \
  --label MODEL_AND_CONFIG \
  --results /tmp/akm-model-eval.jsonl \
  --url CHAT_BASE_URL \
  --model MODEL_ID
```

The URL is the server base without `/v1`. Add `--api lmstudio` for LM Studio's
native response route. Optional request controls include `--repeat-penalty`,
`--seed`, `--max-tokens`, `--timeout`, `--retries`, and `--retry-backoff`. Use `--process`, `--case`, or
`--track` to run a subset. Use `--tier compact` for the fast breadth pass,
`--tier deep --track production` for current AKM workloads, or `--tier context`
for endpoint context qualification. Omitting filters runs all 123 cases.

The chunked graph case makes one endpoint request per production-sized chunk
and stores individual request metrics with the combined case record. Other
cases make one request each.

The runner sets temperature to zero and disables visible reasoning where the
serving API supports that switch. It records raw output, wall time, completion
tokens, finish reason, reasoning fallback, server-reported decode rate, prompt
characters, and the conservative prompt-token estimate used for context bands.

## Score

Scoring reads local files only:

```sh
python3 bench.py score \
  --results /tmp/akm-model-eval.jsonl \
  --label MODEL_AND_CONFIG
```

Add `--require-complete` when the label should contain every selected case. The
report separates tier, track, context-length band, and process and shows schema
passes, full case passes, deterministic check percentage, median prompt and
completion tokens, and median server-reported prefill and decode rates. The
harness never folds compact, legacy, production, or context results into one
score or ranking.

The checks are process-specific. They cover required and forbidden facts,
ordering and contradiction decisions, graph recall and precision, ordered empty
placeholders, chunk merging, empty and duplicate session behavior, prompt-
injection rejection, pass/review/reject quality bands, proposal triage,
frontmatter/code/table/template preservation, metadata grounding, and exact
missing-field repair. They do not claim to measure every aspect of writing
quality or general reasoning.

The legacy grounded scorers additionally check the original bakeoff contract: valid JSON,
three to eight claims, exact source-backed quotes, source coverage, superseded
references for consolidation, and a substantive compressed deliverable. They do
not use an LLM judge.
