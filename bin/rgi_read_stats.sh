#!/usr/bin/env bash
#*******************************************************************************
# rgi_read_stats.sh: how RGI's reads sit on each CARD reference (D19)
#
# RGI bwt (kma) writes no mismatch tags, so they are added from CARD's own
# reference sequences (samtools calmd), then summed per reference over
# primary alignments: reads, reference bases covered (CIGAR M, D, =, X) and
# mismatches (NM). Read identity = 1 - mismatches / bases. A gene that is
# really there gives identity near its DNA identity to the reference; reads
# from a different gene that only shares a stretch with it (a host's own
# partial homolog) sit lower.
#
# Usage:  rgi_read_stats.sh <rgi sorted bam> <card reference fasta>  > stats.tsv
#*******************************************************************************
set -euo pipefail
bam=$1; ref=$2
cp "$ref" ref.fasta           # calmd indexes the FASTA; the staged copy may be read-only
samtools faidx ref.fasta
echo -e "reference\taro_accession\treads\taligned_bases\tmismatches"
samtools calmd -u "$bam" ref.fasta 2>/dev/null | samtools view -F 0x904 - | awk -F'\t' -v OFS='\t' '
    { c = $6; al = 0
      while (match(c, /[0-9]+[MDX=]/)) { al += substr(c, RSTART, RLENGTH - 1); c = substr(c, RSTART + RLENGTH) }
      nm = 0; for (i = 12; i <= NF; i++) if ($i ~ /^NM:i:/) nm = substr($i, 6)
      n[$3]++; b[$3] += al; e[$3] += nm }
    END { for (r in n) { match(r, /ARO:[0-9]+/); print r, substr(r, RSTART + 4, RLENGTH - 4), n[r], b[r], e[r] } }' | sort
rm -f ref.fasta ref.fasta.fai
