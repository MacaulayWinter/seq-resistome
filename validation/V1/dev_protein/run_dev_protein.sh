#!/usr/bin/env bash
#*******************************************************************************
# run_dev_protein.sh: protein-mode DEVELOPMENT run on V1 rounds 3 and 4
#                     (CLAUDE.md D27; design section 5, step 4)
#
# Not validation: both rounds have been seen, and every protein-mode setting
# is chosen here. For one round's scratch folder:
#   1. round 3 only: remake its samples as round 3 made them (ART seed
#      20261030, its three E. coli spikes); its backgrounds and E3 reads are
#      fetched first by fetch_reads.sh (PREREGISTRATION_round3.md section 3)
#   2. the pipeline in protein mode on every sample. -resume reuses the
#      round's own QC, host-removal and 16S tasks where its work folder still
#      holds them; only the DIAMOND steps and the tables are new
#   3. marks 1-4 with score_dev_protein.R (round 4's scorer plus PM5 b)
# Outputs go to <round dir>/results_protein and <round dir>/outcomes_protein.
# Nothing is written to the repository; copy the evidence in by hand.
#
# Usage:  [WORK_DIR=<dir>] PROFILE=docker,arm64 bash validation/V1/dev_protein/run_dev_protein.sh <round dir> <3|4> [nextflow args]
#         WORK_DIR: Nextflow's work folder (default <round dir>/work)
#         e.g. ... ~/seqresistome-scratch/V1r4 4 -c validation/V1/local.config
#*******************************************************************************
set -euo pipefail
v1=$(cd "$1" && pwd); round=$2; shift 2
repo=$(cd "$(dirname "$0")/../../.." && pwd); here="$repo/validation/V1"
profile=${PROFILE:-docker}
work=${WORK_DIR:-$v1/work}
log() { echo "== $(date '+%Y-%m-%d %H:%M') $*"; }
case $round in 3|4) ;; *) echo "run_dev_protein.sh: round must be 3 or 4" >&2; exit 1 ;; esac
echo "pipeline commit: $(git -C "$repo" rev-parse --short HEAD)$(git -C "$repo" diff --quiet HEAD || echo ' (with uncommitted changes)')" \
    | tee "$v1/dev_protein_commit.txt"

if [ "$round" = 3 ]; then
    spikes=GCF_051559745.1,GCF_051563765.1,GCF_051618695.1
    for f in bg_gut bg_wastewater E3_host; do
        [ -s "$v1/reads/${f}_1.fastq.gz" ] || { echo "run_dev_protein.sh: $v1/reads/${f}_1.fastq.gz missing; fetch it first (see Usage)" >&2; exit 1; }
    done
    log "1. round-3 samples (ART seed 20261030)"
    SEED=20261030 bash "$here/build_samples.sh" "$v1/genomes" "$v1/reads" "$spikes"
fi
[ -s "$v1/reads/samplesheet_V1.csv" ] || { echo "run_dev_protein.sh: no $v1/reads/samplesheet_V1.csv" >&2; exit 1; }

log "2. pipeline, protein mode"
cd "$v1"
nextflow -log "$v1/dev_protein_run.log" run "$repo/main.nf" -profile "$profile" -work-dir "$work" -resume \
    --input "$v1/reads/samplesheet_V1.csv" --outdir "$v1/results_protein" --count_mode protein "$@"

log "3. marks 1-4 (development scoring)"
Rscript "$here/dev_protein/score_dev_protein.R" "$v1/results_protein" "$v1/truth" "$v1/outcomes_protein"
log "done"
