#!/usr/bin/env bash
#*******************************************************************************
# simulated_depth.sh: the read depth actually simulated at each truth locus
#                     and each 16S copy (V1 round 4 truth; CLAUDE.md D21)
#
# ART samples read positions at random, and its depth at a gene varies far
# more than chance would give (round 3: 5.5x to 14x in a 10x genome).
# Truth based on nominal depth therefore marks the pipeline wrong for
# reads that were never simulated. Here, each spiked sample's simulated
# reads are mapped back to their own genome, and the mean depth is taken
# over every RGI Perfect/Strict protein-homolog locus and every complete
# barrnap 16S copy. score_V1_round4.R uses these depths as the truth.
#
# Only the spike's reads are used. ART names each read after the contig it
# came from (<contig>-<n>/1), so reads are kept by name, and background
# reads never count.
#
# Tools: kma and samtools from the pipeline's RGI image (kma 1.6.11), or
# from PATH with NATIVE=1.
#
# Usage:  [NATIVE=1] bash validation/V1/simulated_depth.sh <V1 scratch dir> [sample ...]
#         reads <dir>/reads/samplesheet_V1.csv, <dir>/genomes, <dir>/truth;
#         writes <dir>/simulated_depth/<sample>.tsv
#*******************************************************************************
set -euo pipefail
v1=$(cd "$1" && pwd); shift
out="$v1/simulated_depth"; mkdir -p "$out"
IMAGE=community.wave.seqera.io/library/rgi_kma:e905ecb8305e2609
[ "$(uname -m)" = arm64 ] && IMAGE=community.wave.seqera.io/library/rgi_kma:fab5219836c1d880
run() {
    if [ "${NATIVE:-0}" = 1 ]; then "$@"
    else docker run --rm -i -u "$(id -u):$(id -g)" -v "$v1:$v1" -w "$out" "$IMAGE" "$@"; fi
}

sheet="$v1/reads/samplesheet_V1.csv"
samples=${*:-$(awk -F, 'NR > 1 && ($4 == "pure" || $4 == "mixture") { print $1 }' "$sheet")}
for s in $samples; do
    IFS=, read -r _ r1 r2 kind _ g _ < <(awk -F, -v s="$s" '$1 == s' "$sheet")
    [ -n "$g" ] && [ "$g" != none ] || { echo "simulated_depth.sh: $s has no spike genome" >&2; exit 1; }
    fna="$v1/genomes/$g.fna"; tmp="$out/tmp_$s"; mkdir -p "$tmp"

    # Regions: RGI Perfect/Strict protein-homolog ORFs (the truth loci and
    # protein-only hits) and complete 16S copies. 1-based, inclusive.
    awk -F'\t' 'NR == 1 { for (i = 1; i <= NF; i++) h[$i] = i; next }
                $h["Model_type"] == "protein homolog model" && ($h["Cut_Off"] == "Perfect" || $h["Cut_Off"] == "Strict") {
                    c = $h["Contig"]; sub(/_[0-9]+$/, "", c)
                    a = $h["Start"] < $h["Stop"] ? $h["Start"] : $h["Stop"]; b = $h["Start"] < $h["Stop"] ? $h["Stop"] : $h["Start"]
                    print "locus\t" c "\t" a "\t" b }' "$v1/truth/$g.strict.txt" > "$tmp/regions.tsv"
    awk -F'\t' '/Name=16S_rRNA/ && !/partial/ { print "16S\t" $1 "\t" $4 "\t" $5 }' "$v1/truth/$g.barrnap.gff" >> "$tmp/regions.tsv"

    # The spike's reads only, by ART's read names.
    grep '^>' "$fna" | sed 's/^>//; s/ .*//' > "$tmp/contigs.txt"
    for m in 1 2; do
        f=$([ $m = 1 ] && echo "$r1" || echo "$r2")
        gzip -dc "$f" | awk -v C="$tmp/contigs.txt" 'BEGIN { while ((getline l < C) > 0) ok[l] = 1 }
            NR % 4 == 1 { n = substr($1, 2); i = length(n); while (i > 0 && substr(n, i, 1) != "-") i--
                          keep = (i > 1 && substr(n, 1, i - 1) in ok) }
            keep' > "$tmp/spike_$m.fq"
    done

    # kma names each template by its whole FASTA header: keep the accession only.
    sed 's/^\(>[^ ]*\).*/\1/' "$fna" > "$tmp/genome.fna"
    run kma index -i "$tmp/genome.fna" -o "$tmp/genome" > /dev/null 2>&1
    run kma -ipe "$tmp/spike_1.fq" "$tmp/spike_2.fq" -o "$tmp/map" -t_db "$tmp/genome" -1t1 -sam -t 2 2> /dev/null \
        | run samtools sort -o "$tmp/map.bam" - 2> /dev/null
    run samtools index "$tmp/map.bam"
    awk -F'\t' '{ print $2 "\t" $3 - 1 "\t" $4 }' "$tmp/regions.tsv" | sort -u > "$tmp/regions.bed"
    run samtools depth -a -b "$tmp/regions.bed" "$tmp/map.bam" > "$tmp/depth.tsv"
    awk -F'\t' 'BEGIN { OFS = "\t"; print "sample", "genome", "type", "contig", "start", "end", "mean_depth" }
        NR == FNR { d[$1 SUBSEP $2] = $3; next }
        { s = 0; for (p = $3; p <= $4; p++) s += d[$2 SUBSEP p]
          printf "%s\t%s\t%s\t%s\t%d\t%d\t%.4f\n", S, G, $1, $2, $3, $4, s / ($4 - $3 + 1) }' \
        S="$s" G="$g" "$tmp/depth.tsv" "$tmp/regions.tsv" > "$out/$s.tsv"
    echo "$s: $(grep -c '' "$tmp/spike_1.fq" | awk '{ print $1 / 4 }') spike pairs, $(($(wc -l < "$out/$s.tsv") - 1)) regions"
    rm -rf "$tmp"
done
