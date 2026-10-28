#!/usr/bin/env bash
#*******************************************************************************
# truth.sh: the true ARGs and 16S copies of each genome, from its assembly
#           (validation V1, PREREGISTRATION.md section 1)
#
# For each <genome>.fna: RGI main twice (defaults; and --include_loose), and
# barrnap for 16S genes. Same RGI image and CARD release as the pipeline.
#
# Usage:  bash validation/V1/truth.sh <genomes_dir> <card_archive.tar.bz2> <out_dir> [threads]
#*******************************************************************************
set -euo pipefail
gdir=$(cd "$1" && pwd); card=$(cd "$(dirname "$2")" && pwd)/$(basename "$2"); out=$(mkdir -p "$3" && cd "$3" && pwd); threads=${4:-4}
# The pipeline's RGI images (RGI 6.0.8, kma 1.6.11): native arm64 on Apple
# Silicon, amd64 elsewhere. barrnap's image is amd64 only.
case $(uname -m) in arm64|aarch64) RGI_IMAGE=community.wave.seqera.io/library/rgi_kma:fab5219836c1d880; RGI_PLATFORM=linux/arm64 ;;
                    *) RGI_IMAGE=community.wave.seqera.io/library/rgi_kma:e905ecb8305e2609; RGI_PLATFORM=linux/amd64 ;; esac
BARRNAP_IMAGE=quay.io/biocontainers/barrnap:0.9--hdfd78af_4
dock() { local plat=$1; shift; docker run --rm --platform "$plat" -u "$(id -u):$(id -g)" -v "$gdir:/g:ro" -v "$out:/o" -v "$(dirname "$card"):/c:ro" -w /o "$@"; }
run() { dock "$RGI_PLATFORM" "$@"; }

mkdir -p "$out/card"
run "$RGI_IMAGE" bash -c "cd card && tar -xjf /c/$(basename "$card") ./card.json && rgi load --card_json card.json --local > load.log 2>&1 && rgi database --version --local"
for f in "$gdir"/*.fna; do
    g=$(basename "$f" .fna)
    [ -s "$out/$g.strict.txt" ] || run "$RGI_IMAGE" bash -c "cd card && rgi main -i /g/$g.fna -o ../$g.strict -t contig -a DIAMOND -n $threads --local --clean > ../$g.strict.log 2>&1"
    [ -s "$out/$g.loose.txt" ]  || run "$RGI_IMAGE" bash -c "cd card && rgi main -i /g/$g.fna -o ../$g.loose -t contig -a DIAMOND -n $threads --local --clean --include_loose > ../$g.loose.log 2>&1"
    [ -s "$out/$g.barrnap.gff" ] || dock linux/amd64 "$BARRNAP_IMAGE" barrnap --kingdom bac --threads "$threads" --quiet "/g/$g.fna" > "$out/$g.barrnap.gff"
    echo "$g: $(($(wc -l < "$out/$g.strict.txt") - 1)) RGI hits (default), $(grep -c 'Name=16S_rRNA' "$out/$g.barrnap.gff" || true) 16S genes"
done
run "$RGI_IMAGE" bash -c "rgi main --version" > "$out/rgi_version.txt"
