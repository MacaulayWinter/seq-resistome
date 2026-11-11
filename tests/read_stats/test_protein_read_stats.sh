#!/usr/bin/env bash
#*******************************************************************************
# test_protein_read_stats.sh: tests for bin/protein_read_stats.sh (D26, D27)
#
# Hand-made DIAMOND blastx hits (each alignment 30 amino acids) against three
# CARD proteins: A (ARO 3000001, 100 aa), B (3000002, 100 aa), C (3000003,
# 200 aa). min_identity 0.70.
#   mate 1  r1  A 100% at 1-30
#           r2  A  90% at 31-60
#           r3  A and B tied (95%): A has 2 reads of its own, B 1 -> A, at 61-90
#           r4  B  60% at 1-30: below 70%, left out (B: 0 kept, 1 below)
#           r5  C  80% at 11-40; a weaker second hit to A is ignored
#   mate 2  r1  C 100% at 101-130: the other mate of r1, its own read
#           r6  B and C tied (90%): C has 2 of its own, B 1 -> C, at 51-80
# Expected, in nucleotide equivalents (x 3):
#   A  3 reads, 270 aligned, identical 30 + 27 + 29 (28.5 rounded) = 86 aa ->
#      mismatches 3 x 4 = 12; covered 1-90 = 270; length 300; too short for
#      3 windows (NA)
#   B  0 reads, 1 below
#   C  3 reads, 270 aligned, identical 24 + 30 + 27 = 81 -> mismatches 27;
#      covered 270; length 600; 5 windows of 100 bases, read starts in
#      windows 0, 1 and 3 -> mean 0.6, variance 0.3
# With min_identity 0: B keeps its read.
#
#   bash tests/read_stats/test_protein_read_stats.sh
#*******************************************************************************
set -euo pipefail
script=$(cd "$(dirname "$0")/../.." && pwd)/bin/protein_read_stats.sh
d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
cd "$d"
printf 'aro_accession\taro_term\tamr_gene_family\tdrug_class\tresistance_mechanism\tprotein_length\n3000001\tGene A\tfamA\tdrugA\tmechA\t100\n3000002\tGene B\tfamB\tdrugB\tmechB\t100\n3000003\tGene C\tfamC\tdrugC\tmechC\t200\n' > annot.tsv
A='gb|P1|ARO:3000001|A'; B='gb|P2|ARO:3000002|B'; C='gb|P3|ARO:3000003|C'
h() { printf '%s\t%s\t%s\t30\t0\t0\t1\t90\t%s\t%s\t1e-10\t%s\t%s\n' "$@"; }
{ h r1 "$A" 100 1 30 60 100
  h r2 "$A" 90 31 60 55 100
  h r3 "$A" 95 61 90 50 100
  h r3 "$B" 95 1 30 50 100
  h r4 "$B" 60 1 30 30 100
  h r5 "$C" 80 11 40 45 200
  h r5 "$C" 70 41 70 40 200
  h r5 "$A" 75 1 30 40 100; } > m1.tsv
{ h r1 "$C" 100 101 130 60 200
  h r6 "$B" 90 1 30 50 100
  h r6 "$C" 90 51 80 50 200; } > m2.tsv

n_pass=0; fails=0
check() { if [ "$2" = "$3" ]; then n_pass=$((n_pass + 1)); else echo "FAIL: $1: got '$2', expected '$3'"; fails=$((fails + 1)); fi; }
row() { awk -F'\t' -v a="$2" '$2 == a { print $3, $4, $5, $6, $7, $8, $9, $10, $11, $12 }' "$1"; }

bash "$script" s annot.tsv 0.70 m1.tsv m2.tsv
check "A statistics" "$(row s.read_stats.tsv 3000001)" "300 300 3 270 12 270 NA NA NA 0"
check "B left out below 70%" "$(row s.read_stats.tsv 3000002)" "300 300 0 0 0 0 NA NA NA 1"
check "C statistics, ties and mates" "$(row s.read_stats.tsv 3000003)" "600 600 3 270 27 270 5 0.6000 0.3000 0"
check "header" "$(head -1 s.read_stats.tsv | cut -f1-3)" "$(printf 'reference\taro_accession\treference_length')"
check "gene table: names and all reads" "$(awk -F'\t' 'NR > 1 { printf "%s:%s:%s:%s;", $1, $2, $4, $9 }' s.protein_genes.tsv)" "Gene A:3000001:3:famA;Gene B:3000002:1:famB;Gene C:3000003:3:famC;"
check "gene table columns" "$(head -1 s.protein_genes.tsv | tr '\t' ' ')" "aro_term aro_accession model_type reads completely_mapped_reads average_percent_coverage average_mapq reference_length_bp amr_gene_family drug_class resistance_mechanism"
check "no temporary files left" "$(ls | grep -c '^best' || true)" "0"

bash "$script" o annot.tsv 0 m1.tsv m2.tsv
check "B kept with min_identity 0" "$(row o.read_stats.tsv 3000002 | cut -d' ' -f3,10)" "1 0"

# One mate only (single-end) works too.
bash "$script" se annot.tsv 0.70 m1.tsv
check "single-end: C has r5 only" "$(row se.read_stats.tsv 3000003 | cut -d' ' -f3,4)" "1 90"

if [ "$fails" -gt 0 ]; then echo "test_protein_read_stats.sh: $n_pass passed, $fails FAILED"; exit 1; fi
echo "test_protein_read_stats.sh: all $n_pass checks passed"
