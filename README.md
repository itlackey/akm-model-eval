# AKM Model Eval

A frozen public corpus and one standard-library Python script for testing the
model-backed work AKM asks an endpoint to perform.

The suite is compact and balanced:

- `corpus/` contains 30 public, synthetic AKM-style assets about one fictional
  system. No private benchmark material is included.
- `bench.py` contains 48 case mappings, four for each process, plus prompts, the
  endpoint runner, resume logic, deterministic scorers, and scorer calibrations.

There is no generated corpus, downloader, manifest, case file, package install,
or model judge.

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

## Verify

Verification is offline. It checks every corpus path, complete process coverage,
case IDs, every process-specific scorer against a known-good response, rejection
of empty responses, and the publication-safety scan.

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
subset.

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

Add `--require-complete` when the label should contain all 48 cases. The report
shows schema passes, full case passes, deterministic check percentage, and
median server-reported decode rate for each process.

The checks are process-specific. They cover required and forbidden facts,
ordering and contradiction decisions, graph entity/relation recall, empty
session behavior, prompt-injection rejection, quality-judge bands, and metadata
shape. They do not claim to measure every aspect of writing
quality or general reasoning.
