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
# For the per-gene 95% interval (D20), read start positions are also counted
# in 100-base windows along each reference, over the stretch where a whole
# read can start (1 to length - longest alignment + 1). If reads fell at
# random, window counts would vary like a Poisson count (variance = mean);
# window_var / window_mean above 1 means they clump, and the interval is
# widened to match. Fewer than 3 such windows: written as NA.
#
# With CARD's variants collection (D20) a gene's reads are spread over many
# references (CARD's own and variants from sequenced genomes, some only
# fragments), so RGI's per-gene coverage is an average over partly covered
# alleles and its reference length a list. Hence, per reference: its length,
# the bases it has covered by at least one read (covered_bases, for the
# breadth check in its own coordinates), and canonical_length, the length of
# the ARO's own CARD reference sequence (the gene length used for copies).
#
# Usage:  rgi_read_stats.sh <rgi sorted bam> <card reference fasta>  > stats.tsv
#*******************************************************************************
set -euo pipefail
bam=$1; ref=$2
cp "$ref" ref.fasta           # calmd indexes the FASTA; the staged copy may be read-only
samtools faidx ref.fasta
echo -e "reference\taro_accession\treference_length\tcanonical_length\treads\taligned_bases\tmismatches\tcovered_bases\twindows\twindow_mean\twindow_var"
samtools calmd -u "$bam" ref.fasta 2>/dev/null | samtools view -F 0x904 - | awk -F'\t' -v OFS='\t' -v fai=ref.fasta.fai '
    BEGIN { while ((getline line < fai) > 0) {
              split(line, f, "\t"); len[f[1]] = f[2]
              # the CARD reference of the ARO (name starts ARO:<accession>|)
              if (f[1] ~ /^ARO:[0-9]+\|/) { a = substr(f[1], 5); sub(/\|.*/, "", a); if (!(a in canon)) canon[a] = f[2] } } }
    { c = $6; al = 0
      while (match(c, /[0-9]+[MDX=]/)) { al += substr(c, RSTART, RLENGTH - 1); c = substr(c, RSTART + RLENGTH) }
      nm = 0; for (i = 12; i <= NF; i++) if ($i ~ /^NM:i:/) nm = substr($i, 6)
      n[$3]++; b[$3] += al; e[$3] += nm
      if (al > mx[$3]) mx[$3] = al
      st[$3, int(($4 - 1) / 100)]++
      for (p = $4; p < $4 + al; p++) if (!(($3, p) in cv)) { cv[$3, p] = 1; cb[$3]++ } }
    END { for (r in n) {
            match(r, /ARO:[0-9]+/); aro = substr(r, RSTART + 4, RLENGTH - 4)
            w = int((len[r] - mx[r] + 1) / 100)
            if (w >= 3) {
              s1 = 0; s2 = 0
              for (k = 0; k < w; k++) { x = st[r, k] + 0; s1 += x; s2 += x * x }
              m = s1 / w; v = (s2 - w * m * m) / (w - 1)
              wm = sprintf("%.4f", m); wv = sprintf("%.4f", v)
            } else { w = "NA"; wm = "NA"; wv = "NA" }
            cl = (aro in canon) ? canon[aro] : "NA"
            print r, aro, len[r], cl, n[r], b[r], e[r], cb[r] + 0, w, wm, wv } }' | sort
rm -f ref.fasta ref.fasta.fai
