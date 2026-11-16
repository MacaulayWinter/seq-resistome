#!/usr/bin/env bash
#*******************************************************************************
# protein_read_stats.sh: how reads sit on each CARD protein (protein mode;
#                        CLAUDE.md D26, D27)
#
# Input: DIAMOND blastx hits of each mate file against CARD's protein homolog
# proteins, one file per mate, columns
#   qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore slen
# run with --top 0 (every hit tied with the read's best bitscore is listed),
# and DIAMOND_DB's annotation table (aro_accession, aro_term, amr_gene_family,
# drug_class, resistance_mechanism, protein_length).
#
# 1. Each read goes to its best CARD protein by bitscore. A read tied between
#    several AROs goes to the tied ARO with the most reads of its own (reads
#    whose best hit is that ARO alone), then the lowest ARO accession, as in
#    step 0 (D26) and allele merging (D22). Each mate is its own read.
# 2. A read whose amino-acid identity to that protein is below min_identity is
#    left out of every number below and counted in reads_low_identity: reads
#    of paralogs (soxS, rob on marA at ~50%) cannot pull a real gene down.
# 3. Per ARO, written in the same columns as rgi_read_stats.sh, so
#    resistome_tables.R reads both engines alike. Protein coordinates are
#    written as nucleotide equivalents (x 3): lengths, aligned and covered
#    bases and read-start windows of 100 bases. Breadth, copies and the
#    95% interval then use the same formulas as in DNA mode.
#    mismatches = 3 x (aligned amino acids - identical ones), so
#    1 - mismatches / aligned_bases is the kept reads' amino-acid identity
#    weighted by alignment length: the gene identity of rule f70g90.
#
# Writes <prefix>.read_stats.tsv and <prefix>.protein_genes.tsv (every ARO
# with a read, its annotation and all its reads, kept or not; the
# counterpart of RGI's gene_mapping_data.txt).
#
# Usage: protein_read_stats.sh <prefix> <annotation.tsv> <min_identity 0-1> <hits_mate1.tsv> [hits_mate2.tsv]
#
# EXPLORATION COPY (development, 2026-11-13; DIAGNOSIS.md). RULE=mean (the
# default) is bin/protein_read_stats.sh unchanged. RULE=posmax replaces the
# gene identity by the mean, over covered protein positions, of the best kept
# read's identity at that position, so homolog reads from other organisms
# cannot pull a gene that its own reads cover below the threshold. It is
# written through the mismatches column (aligned_bases x (1 - identity)), so
# resistome_tables.R applies --min_protein_gene_identity to it unchanged.
# An extra last column, posmax_identity, is written in every mode.
#*******************************************************************************
set -euo pipefail
prefix=$1; annot=$2; minid=$3; shift 3
[ $# -ge 1 ] || { echo "protein_read_stats.sh: no hit files given" >&2; exit 1; }

# 1a. Best hits of each read: DIAMOND writes a query's hits together, so one
#     pass keeps those tied at the read's top bitscore, one line per ARO.
best=$(mktemp best.XXXXXX)
trap 'rm -f "$best" "$best.n" "$best.g"' EXIT
m=0
for f in "$@"; do
    m=$((m + 1))
    awk -F'\t' -v OFS='\t' -v mate="$m" '
        function flush(   k) { for (k = 1; k <= nb; k++) print mate ":" q, ba[k], nb, bl[k]; nb = 0; delete seenaro }
        { match($2, /ARO:[0-9]+/); aro = substr($2, RSTART + 4, RLENGTH - 4)
          if ($1 != q) { if (q != "") flush(); q = $1; top = $12 + 0 }
          if ($12 + 0 > top) { nb = 0; delete seenaro; top = $12 + 0 }
          if ($12 + 0 == top && !(aro in seenaro)) { seenaro[aro] = 1; nb++; ba[nb] = aro
              s = $9 < $10 ? $9 : $10; e = $9 < $10 ? $10 : $9
              bl[nb] = $2 OFS $3 OFS $4 OFS s OFS e OFS $13 } }
        END { if (q != "") flush() }' "$f" >> "$best"
done
# The number of tied AROs is recounted over the whole file, so it stays right
# even if a read's hits were ever not written together.
awk -F'\t' -v OFS='\t' 'NR == FNR { n[$1]++; next } { $3 = n[$1]; print }' "$best" "$best" > "$best.n"
mv "$best.n" "$best"

# 1b-3. Assign tied reads, filter by identity, sum per ARO.
awk -F'\t' -v OFS='\t' -v rule="${RULE:-mean}" -v minid="$minid" -v annot="$annot" -v genes="${prefix}.protein_genes.tsv" '
    BEGIN { while ((getline line < annot) > 0) { split(line, a, "\t")
              if (a[1] == "aro_accession") continue
              term[a[1]] = a[2]; fam[a[1]] = a[3]; drug[a[1]] = a[4]; mech[a[1]] = a[5] } }
    # pass 1: reads of each ARO alone
    NR == FNR { if ($3 == 1) own[$2]++; next }
    # pass 2: one ARO per read
    { r = $1
      o = ($2 in own) ? own[$2] : 0
      if (!(r in pick) || o > po[r] || (o == po[r] && $2 + 0 < pick[r] + 0)) { pick[r] = $2; po[r] = o; hl[r] = $0 } }
    END {
      for (r in pick) {
        split(hl[r], f, "\t")
        aro = f[2]; ref[aro] = f[4]; id = f[5] + 0; len = f[6] + 0; s = f[7] + 0; e = f[8] + 0; L[aro] = f[9] + 0
        all[aro]++
        if (id < 100 * minid) { lo[aro]++; continue }
        n[aro]++; b[aro] += 3 * len
        ident = int(id * len / 100 + 0.5); mm[aro] += 3 * (len - ident)
        span = 3 * (e - s + 1); if (span > mx[aro]) mx[aro] = span
        st[aro, int(3 * (s - 1) / 100)]++
        for (p = s; p <= e; p++) { if (!((aro, p) in cv)) { cv[aro, p] = 1; cb[aro] += 3 }
                                   if (id > pm[aro, p] + 0) pm[aro, p] = id }
      }
      print "aro_term", "aro_accession", "model_type", "reads", "completely_mapped_reads", "average_percent_coverage",
            "average_mapq", "reference_length_bp", "amr_gene_family", "drug_class", "resistance_mechanism" > genes
      print "reference", "aro_accession", "reference_length", "canonical_length", "reads", "aligned_bases", "mismatches",
            "covered_bases", "windows", "window_mean", "window_var", "reads_low_identity", "posmax_identity"
      for (aro in all) {
        nl = 3 * L[aro]
        w = int((nl - mx[aro] + 1) / 100)
        if (n[aro] > 0 && w >= 3) {
          s1 = 0; s2 = 0
          for (k = 0; k < w; k++) { x = st[aro, k] + 0; s1 += x; s2 += x * x }
          mu = s1 / w; v = (s2 - w * mu * mu) / (w - 1)
          wm = sprintf("%.4f", mu); wv = sprintf("%.4f", v)
        } else { w = "NA"; wm = "NA"; wv = "NA" }
        ps = 0; pc = 0
        for (p = 1; p <= L[aro]; p++) if ((aro, p) in pm) { ps += pm[aro, p]; pc++ }
        pid = pc ? ps / pc / 100 : 0
        if (rule == "posmax" && n[aro] > 0) mm[aro] = int(b[aro] * (1 - pid) + 0.5)
        print ref[aro], aro, nl, nl, n[aro] + 0, b[aro] + 0, mm[aro] + 0, cb[aro] + 0, w, wm, wv, lo[aro] + 0, sprintf("%.4f", pid)
        t = (aro in term) ? term[aro] : ref[aro]
        print t, aro, "protein homolog model", all[aro], "NA", sprintf("%.2f", 100 * (cb[aro] + 0) / nl), "NA", nl,
              fam[aro], drug[aro], mech[aro] > genes
      }
    }' "$best" "$best" | { read -r h; echo "$h"; sort; } > "${prefix}.read_stats.tsv"
{ head -1 "${prefix}.protein_genes.tsv"; tail -n +2 "${prefix}.protein_genes.tsv" | sort -t$'\t' -k2,2; } > "$best.g"
mv "$best.g" "${prefix}.protein_genes.tsv"
rm -f "$best"
