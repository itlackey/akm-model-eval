# AKM Model Eval

A public, deterministic benchmark for comparing how well chat models perform
the work AKM asks an inference endpoint to do.

This repository contains the frozen corpus and a single standard-library Python
runner. It does not download fixtures, call a judge model, or require AKM to be
installed.

This benchmark measures **model capability on AKM-shaped tasks**. It does not
measure whether using AKM improves an agent; [akm-eval](https://github.com/itlackey/akm-eval)
owns that job.

## Requirements

- Python 3.10 or newer;
- a llama.cpp OpenAI-compatible chat endpoint, or LM Studio;
- enough context for the cases you select. The largest context case is about
  65.8K prompt tokens, so a full run needs an endpoint configured above that.

No Python packages are required.

## Quick start

Clone the repository and verify the corpus and scorers offline:

```sh
git clone https://github.com/itlackey/akm-model-eval.git
cd akm-model-eval
python3 bench.py verify
```

Run the 52-case compact suite first:

```sh
python3 bench.py run \
  --label my-model-config \
  --results ./results.jsonl \
  --url http://127.0.0.1:8080 \
  --model my-model-id \
  --tier compact
```

`--url` is the server base URL **without** `/v1`.

Score that run locally:

```sh
python3 bench.py score \
  --results ./results.jsonl \
  --label my-model-config \
  --tier compact \
  --require-complete
```

If those commands succeed, omit `--tier compact` to run and score all 123
cases:

```sh
python3 bench.py run \
  --label my-model-config \
  --results ./results.jsonl \
  --url http://127.0.0.1:8080 \
  --model my-model-id

python3 bench.py score \
  --results ./results.jsonl \
  --label my-model-config \
  --require-complete
```

## Choose the run size

The suite keeps different workload shapes separate rather than folding them
into one score.

| Run | Cases | What it answers | Filter |
| --- | ---: | --- | --- |
| Compact / focused | 52 | Does the model handle the full breadth of AKM processes? | `--tier compact` |
| Deep / production | 29 | Can it handle current, larger AKM request shapes? | `--tier deep --track production` |
| Deep / legacy | 39 | How does it perform on the anonymized original bakeoff workload and its extensions? | `--tier deep --track legacy` |
| Context | 3 | Can the endpoint process approximately 35.8K, 47.7K, and 65.8K prompt tokens? | `--tier context` |
| Full suite | 123 | Run every group above | no tier or track filter |

A practical qualification sequence is:

```sh
# 1. Breadth
python3 bench.py run ... --tier compact

# 2. Current production-shaped work
python3 bench.py run ... --tier deep --track production

# 3. Historical comparison
python3 bench.py run ... --tier deep --track legacy

# 4. Endpoint context limits
python3 bench.py run ... --tier context
```

Replace `...` with the same `--label`, `--results`, `--url`, and `--model`
arguments from the quick-start command. All four commands may append to the
same results file.

## Labels, resuming, and retries

Use a distinct label for every model and serving configuration. Include details
that can affect results, such as quantization, runtime, context size, KV type,
slot count, and hardware placement.

`run` appends one JSON object per attempt. Re-running the same command with the
same label and results file skips successful cases and resumes incomplete ones.
Failed attempts remain in the JSONL evidence, while scoring uses the latest
attempt for each case.

Transport failures and HTTP 408, 425, 429, 500, 502, 503, and 504 responses are
retried five times with exponential backoff by default. Adjust this with
`--retries` and `--retry-backoff`.

The runner and scorer record the suite fingerprint and reject results produced
by a different corpus or case revision.

## Endpoint options

llama.cpp is the default:

```sh
python3 bench.py run \
  --label llama-example \
  --results ./results.jsonl \
  --url http://127.0.0.1:8080 \
  --model model-alias
```

For LM Studio's native response route, add:

```sh
--api lmstudio
```

For an authenticated endpoint, place the key in an environment variable and
name it without exposing its value:

```sh
--api-key-env MODEL_API_KEY
```

Optional request controls include `--repeat-penalty`, `--seed`, `--max-tokens`,
and `--timeout`. The runner sets temperature to zero and disables visible
reasoning where the serving API supports it.

## Run a smaller selection

Inspect the complete process and case inventory:

```sh
python3 bench.py list
```

Run one process, one case, or the first few selected cases:

```sh
python3 bench.py run ... --process graph_extraction
python3 bench.py run ... --case prod-session-complex-extraction
python3 bench.py run ... --tier compact --limit 5
```

`--tier`, `--track`, `--process`, and `--case` are repeatable.

See every supported option with:

```sh
python3 bench.py run --help
python3 bench.py score --help
```

## Read the score report

Scoring reads local result files only. It reports results separately by tier,
track, context-length band, and process, including:

- structurally valid responses;
- full case passes;
- deterministic check percentage;
- median prompt and completion tokens;
- median server-reported prefill and decode rates, when the server supplies
  them.

Use `--require-complete` when every case selected by the score command must be
present. Omit it while inspecting an in-progress run.

The harness never combines compact, legacy, production, and context results
into one ranking. Throughput is also meaningful only when the request shape is
stated.

## What the suite covers

The corpus contains 141 checked-in files and 123 cases across 13 model-backed
AKM processes:

- memory consolidation;
- knowledge and lesson distillation;
- memory inference;
- graph extraction;
- metadata enhancement;
- lesson quality judgment;
- proposal quality judgment;
- memory contradiction detection;
- session extraction and session summaries;
- reflection proposals;
- `remember` enrichment;
- schema repair;
- proposal triage.

The process inventory was checked against the live model-feature call sites in
`itlackey/akm` commit `7c50f57c8e2da101f2b9226e5fbaa7d9c7cab0e5`.
Curate reranking is deliberately excluded because it uses a dedicated
cross-encoder and a different request protocol.

### Compact / focused

The compact tier has four focused cases for each process. Its synthetic assets
describe one fictional system and expose precise facts that deterministic
checks can verify.

### Deep / legacy

The legacy track contains the original bakeoff's 24-item consolidation and
distillation workload, built from 49 anonymized source documents, plus 15 cases
covering long-document graph extraction, grounded revision, proposal-quality
judgment, and multi-document synthesis.

Names, identifiers, internal paths, and dates were replaced with stable generic
aliases. Document ordering, structure, numeric constraints, and overlap between
versions were retained. There is no mapping back to private item IDs.

### Deep / production

The production track covers current AKM request shapes: 20–35-memory pools,
distillation and review-band judgments, ordered graph batches, chunk merging,
grounded revisions, complex session extraction, metadata enhancement, and
schema repair across six asset types.

### Context

The context tier runs otherwise identical extraction work at approximately
35.8K, 47.7K, and 65.8K prompt tokens. It qualifies endpoint limits separately
from model accuracy.

## Scoring boundaries

Checks are process-specific. They cover required and forbidden facts, ordering,
contradiction decisions, graph recall and precision, empty placeholders, chunk
merging, duplicate handling, prompt-injection rejection, quality bands,
frontmatter and template preservation, metadata grounding, and missing-field
repair.

Legacy grounding checks additionally require valid JSON, source-backed quotes,
source coverage, superseded references for consolidation, and a substantive
compressed deliverable.

The benchmark does not claim to measure every aspect of writing quality or
general reasoning, and it does not use an LLM judge.
