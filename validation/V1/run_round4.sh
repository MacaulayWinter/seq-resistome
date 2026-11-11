#!/usr/bin/env bash
#*******************************************************************************
# run_round4.sh: validation V1 round 4, end to end (PREREGISTRATION_round4.md)
#
# Applies the pre-registered data rules (section 3), builds the samples, the
# truth and the simulated depths, runs the pipeline, E4 and the CARD cache
# (mark 5), and scores marks 1-4 with score_V1_round4.R. Each step skips work
# already done, so the script can be run again after an interruption.
#
# Refuses to start while the pre-registration is still a draft: data is
# chosen only after the commit that puts it in force.
#
# Data rules, as written:
#   spikes      genomes_round3.tsv, draws not yet used (no role), in draw
#               order; the first three whose species differ from each other
#   backgrounds per type, candidates_<type>.tsv in draw order after backup 2;
#               the first paired-end Illumina run that can be fetched; its
#               first 1,000,000 pairs
#   simulation  ART seed 20261105; E3 = HG002 (SRR37356339) pairs
#               600,001-800,000; E4 = round 4's first spike genome
#
# Usage:  [PROFILE=docker,arm64] bash validation/V1/run_round4.sh <round-4 scratch dir> <seq-triage repo> <kraken2 db dir> [nextflow args]
#         e.g. PROFILE=docker,arm64 bash validation/V1/run_round4.sh ~/seqresistome-scratch/V1r4 ~/Projects/seq-triage \
#                  ~/seqtriage-scratch/k2_std8_20251015 -c validation/V1/local.config
#         The profile goes in PROFILE (run_V1.sh and run_E4.sh add it to every
#         run; a -profile in the arguments would replace the CARD-cache runs'
#         "test"), never in the nextflow arguments.
#*******************************************************************************
set -euo pipefail
for a in "$@"; do [ "$a" = -profile ] && { echo "run_round4.sh: give the profile in PROFILE, not -profile (see Usage)" >&2; exit 1; }; done
v1=$(mkdir -p "$1" && cd "$1" && pwd); triage_src=$(cd "$2" && pwd); k2=$(cd "$3" && pwd); shift 3
repo=$(cd "$(dirname "$0")/../.." && pwd); here="$repo/validation/V1"
card=${CARD_ARCHIVE:-$HOME/.seq-resistome/card/broadstreet-v4.0.2.tar.bz2}
E1E2_GENOMES=${E1E2_GENOMES:-$HOME/seqresistome-scratch/V1r3/genomes}   # M. genitalium, phage lambda (as rounds 1-3)
TRIAGE_COMMIT=fbf74dd
log() { echo "== $(date '+%Y-%m-%d %H:%M') $*"; }

if grep -q "DRAFT, not yet in force" "$here/PREREGISTRATION_round4.md"; then
    echo "run_round4.sh: PREREGISTRATION_round4.md is still a draft; commit it in force first." >&2; exit 1; fi
git -C "$repo" diff --quiet HEAD -- "$here/PREREGISTRATION_round4.md" ||
    { echo "run_round4.sh: PREREGISTRATION_round4.md has uncommitted changes." >&2; exit 1; }
echo "pipeline commit: $(git -C "$repo" rev-parse --short HEAD)" | tee "$v1/round4_commit.txt"
mkdir -p "$v1/genomes" "$v1/reads" "$v1/truth"

# 1. Spike genomes ---------------------------------------------------------------
if [ ! -s "$v1/genomes_round4.tsv" ]; then
    awk -F'\t' 'NR == 1 { for (i = 1; i <= NF; i++) h[$i] = i; print; next }
                $h["role"] == "" && !($h["organism"] in seen) && n < 3 { seen[$h["organism"]] = 1; n++; print }' \
        "$here/genomes_round3.tsv" > "$v1/genomes_round4.tsv"
fi
spikes=$(awk -F'\t' 'NR > 1 { printf "%s%s", (NR > 2 ? "," : ""), $1 }' "$v1/genomes_round4.tsv")
log "1. spikes: $spikes"
for g in ${spikes//,/ }; do
    [ -s "$v1/genomes/$g.fna" ] && continue
    d=$(mktemp -d)
    curl -sSfL -o "$d/g.zip" "https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$g/download?include_annotation_type=GENOME_FASTA"
    unzip -q -o "$d/g.zip" -d "$d"
    cat "$d"/ncbi_dataset/data/"$g"/*.fna > "$v1/genomes/$g.fna"
    rm -rf "$d"
    [ "$(grep -c '^>' "$v1/genomes/$g.fna")" -ge 1 ] || { echo "run_round4.sh: $g downloaded no sequence" >&2; exit 1; }
done
for g in NC_000908.2 NC_001416.1; do [ -s "$v1/genomes/$g.fna" ] || cp "$E1E2_GENOMES/$g.fna" "$v1/genomes/"; done

# 2. Backgrounds and E3 ---------------------------------------------------------------
for t in human_gut:gut wastewater:wastewater; do
    type=${t%%:*}; short=${t##*:}
    [ -s "$v1/reads/bg_${short}_1.fastq.gz" ] && continue
    picked=""
    while IFS=$'\t' read -r run model ftp; do
        case $model in *Illumina*|*NextSeq*|*NovaSeq*|*HiSeq*|*MiSeq*) ;; *) echo "  $run: $model, not Illumina; next"; continue ;; esac
        case $ftp in *_1.fastq.gz*_2.fastq.gz*) ;; *) echo "  $run: not paired-end; next"; continue ;; esac
        if bash "$here/fetch_reads.sh" "$run" 1000000 "$v1/reads/bg_${short}"; then picked=$run; break; fi
        echo "  $run: could not be fetched; next"
    done < <(awk -F'\t' 'NR == 1 { for (i = 1; i <= NF; i++) h[$i] = i; next }
                         { r[$h["draw"]] = $h["run_accession"] "\t" $h["instrument_model"] "\t" $h["fastq_ftp"]; if ($h["role"] == "backup 2") b2 = $h["draw"] }
                         END { for (d = b2 + 1; d in r; d++) print r[d] }' "$here/candidates_${type}.tsv")
    [ -n "$picked" ] || { echo "run_round4.sh: no $type background could be fetched" >&2; exit 1; }
    printf '%s\t%s\n' "$type" "$picked" >> "$v1/backgrounds_round4.tsv"
done
log "2. backgrounds: $(tr '\n' ' ' < "$v1/backgrounds_round4.tsv")"
[ -s "$v1/reads/E3_host_1.fastq.gz" ] || SKIP=600000 bash "$here/fetch_reads.sh" SRR37356339 200000 "$v1/reads/E3_host"

# 3. Samples (ART seed 20261105) --------------------------------------------------------
log "3. samples"
SEED=20261105 bash "$here/build_samples.sh" "$v1/genomes" "$v1/reads" "$spikes"

# 4. Truth: RGI main and barrnap, findable genes, where CARD genes lie ------------------------
log "4. truth"
bash "$here/truth.sh" "$v1/genomes" "$card" "$v1/truth"
bash "$here/truth_findable.sh" "$v1/truth" "$card"
bash "$here/locate.sh" "$v1/genomes" "$v1/truth"

# 5. Simulated depth (the truth's depths; D21), in the pipeline's RGI image ------------------
log "5. simulated depth"
bash "$here/simulated_depth.sh" "$v1"

# 6. Pipeline, marks 1-4 (score_V1_round4.R) and mark 5 (the CARD cache) ---------------------
log "6. pipeline, marks 1-5"
SCORER=score_V1_round4.R bash "$here/run_V1.sh" "$v1" "$@"

# 7. E4: seq-triage at its fixed commit, then seq-resistome on its results ----------------
log "7. E4"
if [ ! -d "$v1/seq-triage" ]; then
    git clone -q "$triage_src" "$v1/seq-triage"
    git -C "$v1/seq-triage" checkout -q "$TRIAGE_COMMIT"
fi
E4_GENOME=${spikes%%,*} bash "$here/run_E4.sh" "$v1" "$v1/seq-triage" "$k2" "$@" -c "$here/e4.config"
log "done"
