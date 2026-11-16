#!/usr/bin/env bash
#*******************************************************************************
# run_step0.sh: protein-mode step 0 (development only; design doc section 4)
#
# DIAMOND blastx of pure-genome reads against CARD 4.0.2's protein homolog
# proteins. Round 4's three pure genomes (reads already made) and round 3's
# three pure E. coli genomes (re-made with ART, seed 20261030, identical to the
# round-3 reads). One container at a time; DIAMOND keeps only each read's
# best-scoring hits (--top 0), and the re-made reads are deleted after use.
# New disk: about 0.3 GB (DIAMOND image ~0.1 GB, reads ~0.12 GB, hits).
# Then score_step0.R.
#
# Usage: bash run_step0.sh <step0 work dir>
#*******************************************************************************
set -euo pipefail
w=$(mkdir -p "$1" && cd "$1" && pwd)
here=$(cd "$(dirname "$0")" && pwd)
DIAMOND_IMAGE=quay.io/biocontainers/diamond:2.2.8--he361c42_0
ART_IMAGE=quay.io/biocontainers/art:2016.06.05--h0704011_13
r4=$HOME/seqresistome-scratch/V1r4; r3=$HOME/seqresistome-scratch/V1r3
card=${CARD_ARCHIVE:-$HOME/.seq-resistome/card/broadstreet-v4.0.2.tar.bz2}
log() { echo "== $(date '+%H:%M:%S') $*"; }
dk() { docker run --rm --name "step0-$RANDOM" --platform linux/amd64 --memory=6g -u "$(id -u):$(id -g)" "$@"; }

mkdir -p "$w/card" "$w/reads_r3" "$w/hits"
[ -s "$w/card/protein_fasta_protein_homolog_model.fasta" ] ||
    tar -xjf "$card" -C "$w/card" ./card.json ./protein_fasta_protein_homolog_model.fasta
if [ ! -s "$w/card/card_protein.dmnd" ]; then
    log "diamond makedb"
    dk -v "$w/card:/c" "$DIAMOND_IMAGE" diamond makedb --in /c/protein_fasta_protein_homolog_model.fasta -d /c/card_protein --quiet
fi

# Round-3 pure E. coli reads, re-made exactly as build_samples.sh made them
for g in GCF_051559745.1 GCF_051563765.1 GCF_051618695.1; do
    o=$w/reads_r3/pure_$g
    [ -s "${o}_1.fastq.gz" ] && continue
    log "ART $g"
    dk -v "$r3/genomes:/g:ro" -v "$w/reads_r3:/r" -w /r "$ART_IMAGE" \
        art_illumina -ss HS25 -i "/g/$g.fna" -p -l 150 -f 10 -m 350 -s 50 -rs 20261030 -na -q -o "pure_${g}_" > /dev/null
    gzip -1 -c "${o}_1.fq" > "${o}_1.fastq.gz"; gzip -1 -c "${o}_2.fq" > "${o}_2.fastq.gz"; rm "${o}_1.fq" "${o}_2.fq"
done

blastx() {  # blastx <reads dir> <sample>
    local d=$1 s=$2 m
    for m in 1 2; do
        local out=$w/hits/${s}_$m.tsv
        [ -s "$out" ] && continue
        log "blastx $s mate $m"
        local t0=$SECONDS
        dk -v "$d:/r:ro" -v "$w/card:/c:ro" -v "$w/hits:/h" "$DIAMOND_IMAGE" \
            diamond blastx -q "/r/${s}_$m.fastq.gz" -d /c/card_protein -o "/h/${s}_$m.tsv.part" \
            --sensitive --top 0 --max-hsps 1 --evalue 1e-5 -b 1 -c 4 --threads 4 --quiet \
            --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore slen
        mv "$out.part" "$out"
        echo "$s mate $m seconds $((SECONDS - t0))" >> "$w/hits/timing.txt"
    done
}
for g in GCF_051561185.1 GCF_051562295.1 GCF_051617105.1; do blastx "$r4/reads" "pure_$g"; done
for g in GCF_051559745.1 GCF_051563765.1 GCF_051618695.1; do blastx "$w/reads_r3" "pure_$g"; done
rm -rf "$w/reads_r3"   # re-made reads, no longer needed (about 120 MB)
log "blastx done; new disk in $w: $(du -sh "$w" | cut -f1)"
