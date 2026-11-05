#!/usr/bin/env bash
#*******************************************************************************
# build_samples.sh: make every V1 test sample (PREREGISTRATION.md section 2)
#
# Reads are simulated with ART (HiSeq 2500 profile, 2 x 150 bp, fragments
# 350 +/- 50, seed $SEED: 20261028 in round 1, 20261029 in round 2), every replicon at the same depth. Mixtures are
# a background's pairs followed by the spike's simulated pairs. Writes the
# reads and samplesheet_V1.csv into <reads_dir> (outside the repository),
# with the design (background, spike, depth) as study metadata columns.
#
# Usage:  bash validation/V1/build_samples.sh <genomes_dir> <reads_dir> <spike accessions, comma-separated>
#*******************************************************************************
set -euo pipefail
gdir=$(cd "$1" && pwd); rdir=$(cd "$2" && pwd); spikes=$3
ART_IMAGE=quay.io/biocontainers/art:2016.06.05--h0704011_13
SEED=${SEED:-20261028}
DEPTHS="0.5 2 8"
art() {   # art <genome accession> <depth> <out prefix>: simulated pairs, gzipped
    local g=$1 depth=$2 out=$3
    [ -s "${out}_1.fastq.gz" ] && return
    docker run --rm --platform linux/amd64 -u "$(id -u):$(id -g)" -v "$gdir:/g:ro" -v "$rdir:/r" -w /r "$ART_IMAGE" \
        art_illumina -ss HS25 -i "/g/$g.fna" -p -l 150 -f "$depth" -m 350 -s 50 -rs "$SEED" -na -q -o "$(basename "$out")_" > /dev/null
    gzip -1 -c "${out}_1.fq" > "${out}_1.fastq.gz"; gzip -1 -c "${out}_2.fq" > "${out}_2.fastq.gz"; rm "${out}_1.fq" "${out}_2.fq"
}
sheet=$rdir/samplesheet_V1.csv
echo "sample,fastq_1,fastq_2,kind,background,spike,spike_depth" > "$sheet"
row() { echo "$1,$rdir/$1_1.fastq.gz,$rdir/$1_2.fastq.gz,$2,$3,$4,$5" >> "$sheet"; }

for bg in gut wastewater; do row "bg_$bg" background "$bg" none 0; done
for g in ${spikes//,/ }; do
    art "$g" 10 "$rdir/pure_$g"
    row "pure_$g" pure none "$g" 10
    for d in $DEPTHS; do
        art "$g" "$d" "$rdir/spike_${g}_${d}x"
        for bg in gut wastewater; do
            s="mix_${bg}_${g}_${d}x"
            if [ ! -s "$rdir/${s}_1.fastq.gz" ]; then
                for m in 1 2; do cat "$rdir/bg_${bg}_${m}.fastq.gz" "$rdir/spike_${g}_${d}x_${m}.fastq.gz" > "$rdir/${s}_${m}.fastq.gz"; done
            fi
            row "$s" mixture "$bg" "$g" "$d"
        done
    done
done
art NC_000908.2 10 "$rdir/E1_mgenitalium"; row E1_mgenitalium edge_no_arg none NC_000908.2 10
art NC_001416.1 10 "$rdir/E2_lambda";      row E2_lambda edge_no_16s none NC_001416.1 10
row E3_host edge_host_only none HG002 0
wc -l < "$sheet" | awk '{print $1 - 1 " samples in samplesheet_V1.csv"}'
