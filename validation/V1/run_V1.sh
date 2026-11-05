#!/usr/bin/env bash
#*******************************************************************************
# run_V1.sh: run validation V1 end to end (PREREGISTRATION.md)
#
#   1. the pipeline on every V1 sample (samplesheet_V1.csv, from build_samples.sh)
#   2. marks 1-4 (score_V1.R)
#   3. mark 5, the CARD cache, with the real cache and card.mcmaster.ca:
#      a run that must download nothing, then a run after bytes are appended
#      to the cached archive, which must detect it, fetch again and finish
#      with the pinned checksum. Both use the tiny test profile.
#
# Usage:  [SCORER=score_V1_round2.R] bash validation/V1/run_V1.sh <V1 scratch dir> [extra nextflow args, e.g. -c validation/V1/local.config -profile docker,arm64]
#         <V1 scratch dir> holds reads/ (with samplesheet_V1.csv), truth/, genomes/
#*******************************************************************************
set -euo pipefail
v1=$(cd "$1" && pwd); shift
repo=$(cd "$(dirname "$0")/../.." && pwd)
profile=${PROFILE:-docker}
R_IMAGE=docker.io/rocker/r-ver:4.5.2@sha256:fd4ccdd3a4a6f7ef805e2daeee2a0fe3bf126bc231f36351223baecf5a595a4c
cd "$v1"

echo "== 1. pipeline on every V1 sample"
nextflow -log "$v1/V1_run.log" run "$repo/main.nf" -profile "$profile" -work-dir "$v1/work" -resume \
    --input "$v1/reads/samplesheet_V1.csv" --outdir "$v1/results" "$@"

echo "== 2. marks 1-4"
docker run --rm -u "$(id -u):$(id -g)" -v "$v1:/v" -v "$repo:/repo:ro" -w /v "$R_IMAGE" \
    Rscript "/repo/validation/V1/${SCORER:-score_V1.R}" /v/results /v/truth /v/outcomes

echo "== 3. mark 5: the CARD cache (real cache, card.mcmaster.ca)"
# From a folder of its own: -resume resumes the last run launched in a
# folder, and these small runs must not become "the last V1 run" (they did
# once, and a later -resume redid every V1 task).
mkdir -p "$v1/cache_test"; cd "$v1/cache_test"
cache=${CARD_CACHE:-$HOME/.seq-resistome/card}
archive=$cache/broadstreet-v4.0.2.tar.bz2
pinned=$(awk -F, '$2 == "validated" {print $4}' "$repo/assets/card_versions.csv")
nextflow -log "$v1/cache_reuse.log" run "$repo/main.nf" -profile "test,$profile" -work-dir "$v1/work_cache" \
    --outdir "$v1/cache_reuse" "$@" > /dev/null
reuse=$(grep -c 'reused from the cache (checksum matches; nothing downloaded)' "$v1/cache_reuse.log" || true)
printf 'damage' >> "$archive"
nextflow -log "$v1/cache_refetch.log" run "$repo/main.nf" -profile "test,$profile" -work-dir "$v1/work_cache" \
    --outdir "$v1/cache_refetch" "$@" > /dev/null
warned=$(grep -c 'does not match the recorded' "$v1/cache_refetch.log" || true)
refetched=$(grep -c 'fetched again (the cached copy failed its checksum)' "$v1/cache_refetch.log" || true)
now=$( (shasum -a 256 "$archive" 2>/dev/null || sha256sum "$archive") | cut -d' ' -f1)
ok=$([ "$reuse" -ge 1 ] && [ "$warned" -ge 1 ] && [ "$refetched" -ge 1 ] && [ "$now" = "$pinned" ] && \
     grep -q 'CARD 4.0.2' "$v1/cache_refetch/resistome_summary.md" && echo PASS || echo FAIL)
mkdir -p "$v1/outcomes"
printf 'check\tresult\nsecond run reused the cache\t%s\ndamage reported\t%s\nfetched again\t%s\narchive checksum after the run\t%s\npinned checksum\t%s\nmark 5\t%s\n' \
    "$reuse" "$warned" "$refetched" "$now" "$pinned" "$ok" > "$v1/outcomes/mark5_card_cache.tsv"
cat "$v1/outcomes/mark5_card_cache.tsv"
