# AKM Model Eval

A frozen public corpus and one standard-library Python script for comparing
models on the work AKM asks an endpoint to perform. This is a model capability
benchmark. It does not measure whether AKM itself improves an agent; `akm-eval`
owns that job.

The suite has two workload tiers:

- `compact` contains 48 focused cases, four for each of AKM's 12 model-backed
  processes. Its 30 synthetic assets describe one fictional system and expose
  precise facts that deterministic checks can verify.
- `deep` contains 39 cases. Its core is the bakeoff's original 24-item workload:
  12 consolidations and 12 distillations built from 49 static source documents.
  Client/project names, user and session identifiers, internal paths, dates, and
  the original item IDs were replaced with stable generic aliases. Document
  count, ordering, structure, numeric constraints, and overlap between versions
  were retained.
- The other 15 deep cases add work the original bakeoff did not cover: four
  long-document graph extractions, four grounded revisions, four proposal-quality
  judgments, and three multi-document syntheses. They use 15 exact documents
  copied from the public AKM revisions named in their corpus paths. The largest
  case contains 118,767 source characters.

The anonymized fixtures preserve the original workload, not byte identity, so
new scores are not numerically interchangeable with results from the private
bakeoff corpus. There is deliberately no mapping back to its private IDs.
Everything needed to run is checked in: there is no corpus generator,
downloader, package install, separate case file, or model judge.

## Coverage

The process inventory was checked against the live model-feature call sites in
`itlackey/akm` commit `7c50f57c8e2da101f2b9226e5fbaa7d9c7cab0e5`.
The suite covers all 12 chat-completion process keys with real call sites at
that revision:

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
- schema repair.

Curate reranking is deliberately excluded. It uses a dedicated cross-encoder,
a different request protocol, and a different model; it does not measure a chat
model's ability to perform AKM work.

Run the coverage inventory at any time:

```sh
python3 bench.py list
```

The compact tier supplies process breadth and precise regression checks. The
deep tier tests long, complicated work where context actually matters:
reconciling overlapping knowledge, preserving constraints during distillation,
extracting a graph from a substantial document, revising without inventing
facts, judging a large proposed change, and synthesizing several sources. Short
schema and classification calls are not padded to look long.

## Verify

Verification is offline. It checks the exact corpus inventory, all 49 anonymized
bakeoff documents, complete process coverage, case IDs, every process-specific
scorer against a known-good response, rejection of empty responses, exact-quote
grounding failures, and publication-safety markers.

```sh
python3 bench.py verify
```

## Run chat cases

`run` appends one JSON object per case and resumes completed case-and-label
pairs. Supply a distinct label for each model or server configuration. Results
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
`--seed`, `--max-tokens`, and `--timeout`. Use `--process` or `--case` to run a
subset. Use `--tier compact` for the fast breadth pass or `--tier deep` for the
long-context pass; omitting it runs all 87 cases.

The runner sets temperature to zero and disables visible reasoning where the
serving API supports that switch. It records raw output, wall time, completion
tokens, finish reason, reasoning fallback, and server-reported decode rate.

## Score

Scoring reads local files only:

```sh
python3 bench.py score \
  --results /tmp/akm-model-eval.jsonl \
  --label MODEL_AND_CONFIG
```

Add `--require-complete` when the label should contain every selected case. The
report separates compact and deep results and shows schema passes, full case
passes, deterministic check percentage, median prompt and completion tokens,
and median server-reported decode rate for each process. The harness never folds
the two tiers into one score or ranking.

The checks are process-specific. They cover required and forbidden facts,
ordering and contradiction decisions, graph entity/relation recall, empty
session behavior, prompt-injection rejection, quality-judge bands, and metadata
shape. They do not claim to measure every aspect of writing
quality or general reasoning.

The deep scorers additionally check the original bakeoff contract: valid JSON,
three to eight claims, exact source-backed quotes, source coverage, superseded
references for consolidation, and a substantive compressed deliverable. They do
not use an LLM judge.
