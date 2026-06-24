#!/usr/bin/env bash
# FLINT conformance cross-check for the released `hex-gram-schmidt` repo.
#
# Single-library version of the monorepo's oracle runner: emit a fresh
# fixture set from Lean, diff it against the committed fixture, then pipe
# the fresh emission into the python-flint oracle (`gs_flint.py`). Any
# non-zero step fails the job.
#
# Run from the repository root, after `lake build` and the conformance
# library build. python-flint must already be installed.

set -uo pipefail

lib="HexGramSchmidt"
fixture="conformance-fixtures/HexGramSchmidt/gram_schmidt.jsonl"
fresh="/tmp/HexGramSchmidt-fresh.jsonl"

echo "=========================================================="
echo ">>> $lib :: emit=hexgramschmidt_emit_fixtures oracle=scripts/oracle/gs_flint.py"
echo "=========================================================="

if ! (cd conformance && lake exe hexgramschmidt_emit_fixtures) >"$fresh"; then
  echo "FAIL: $lib :: lake exe hexgramschmidt_emit_fixtures exited non-zero" >&2
  exit 1
fi

if ! diff -u "$fixture" "$fresh"; then
  echo "FAIL: $lib :: fresh emission diverges from committed fixture" >&2
  exit 1
fi

if ! python3 scripts/oracle/gs_flint.py <"$fresh"; then
  echo "FAIL: $lib :: oracle scripts/oracle/gs_flint.py reported a divergence" >&2
  exit 1
fi

echo
echo "Conformance: $lib oracle passed."
