#!/usr/bin/env bash
# Writes the Dockerfile for one runtime and version by asking the LaraKube CLI, which owns what a
# workspace image contains. Set LARAKUBE to a different binary to use one built from source.
#   scripts/render.sh <runtime> <version> <output-dir>
set -euo pipefail

runtime="${1:?runtime}"
version="${2:?version}"
out="${3:?output dir}"

mkdir -p "$out"
"${LARAKUBE:-larakube}" workspace:dockerfile --runtime="$runtime" --runtime-version="$version" --no-interaction > "$out/Dockerfile"
