#!/usr/bin/env bash
# Print queue depth and checkpoint state for a non-mutating recovery inspection.
# Use this before choosing a stalled-queue recovery action. The script never
# pauses publishers, renames artifacts, or advances the checkpoint.
set -euo pipefail

depth="$(relayctl queue depth --format value)"
checkpoint="$(relayctl checkpoint show --format value)"
printf '{"depth":%s,"checkpoint":%s}\n' "$depth" "$checkpoint"
