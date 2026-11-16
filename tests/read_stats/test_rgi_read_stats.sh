#!/usr/bin/env bash
#*******************************************************************************
# test_rgi_read_stats.sh: tests for bin/rgi_read_stats.sh (D19, D20, D23)
#
# A hand-built reference and BAM with reads whose matches are known:
#   X (ARO 3000001, 200 bp): three 50-base reads at 1, 51 and 101; the first
#     two match exactly, the third has 10 mismatches (identity 0.80).
#   Y (ARO 3000002, 200 bp): one 50-base read with 20 mismatches (0.60).
# With min_identity 0.85: X keeps 2 reads (100 bases, 0 mismatches, 100
# covered) and reports 1 below; Y keeps none and is still listed (0 kept,
# 1 below). With min_identity 0 (off): X has 3 reads and 10 mismatches.
#
# Needs samtools (the pipeline's RGI image has it):
#   docker run --rm -v "$PWD":/w -w /w <rgi image> bash tests/read_stats/test_rgi_read_stats.sh
#*******************************************************************************
set -euo pipefail
script=$(cd "$(dirname "$0")/../.." && pwd)/bin/rgi_read_stats.sh
d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
cd "$d"

# Two 200-base references from a fixed pattern (no randomness).
seqx=$(awk 'BEGIN { b = "ACGT"; for (i = 0; i < 200; i++) printf "%s", substr(b, (i * 7 + int(i / 3)) % 4 + 1, 1) }')
seqy=$(awk 'BEGIN { b = "ACGT"; for (i = 0; i < 200; i++) printf "%s", substr(b, (i * 5 + int(i / 2)) % 4 + 1, 1) }')
printf '>ARO:3000001|ID:1|Name:X\n%s\n>ARO:3000002|ID:2|Name:Y\n%s\n' "$seqx" "$seqy" > card_ref.fasta
# Change k bases (every 2nd) of a read so they no longer match.
mut() { echo "$1" | awk -v k="$2" '{ s = $0; n = 0
          for (i = 1; i <= length(s) && n < k; i += 2) { c = substr(s, i, 1); r = (c == "A") ? "C" : "A"; s = substr(s, 1, i - 1) r substr(s, i + 1); n++ }
          print s }'; }
q=$(printf 'I%.0s' $(seq 1 50))
{
  printf '@HD\tVN:1.6\tSO:coordinate\n'
  printf '@SQ\tSN:ARO:3000001|ID:1|Name:X\tLN:200\n@SQ\tSN:ARO:3000002|ID:2|Name:Y\tLN:200\n'
  printf 'r1\t0\tARO:3000001|ID:1|Name:X\t1\t60\t50M\t*\t0\t0\t%s\t%s\n'   "${seqx:0:50}" "$q"
  printf 'r2\t0\tARO:3000001|ID:1|Name:X\t51\t60\t50M\t*\t0\t0\t%s\t%s\n'  "${seqx:50:50}" "$q"
  printf 'r3\t0\tARO:3000001|ID:1|Name:X\t101\t60\t50M\t*\t0\t0\t%s\t%s\n' "$(mut "${seqx:100:50}" 10)" "$q"
  printf 'r4\t0\tARO:3000002|ID:2|Name:Y\t1\t60\t50M\t*\t0\t0\t%s\t%s\n'   "$(mut "${seqy:0:50}" 20)" "$q"
} > in.sam
samtools view -b -o in.bam in.sam

pass=0; fail=0
ok() { if eval "$1"; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "  FAILED: $2"; fi; }
col() { awk -F'\t' -v a="$2" -v c="$3" 'NR == 1 { for (i = 1; i <= NF; i++) h[$i] = i; next } $2 == a { print $h[c] }' "$1"; }

bash "$script" in.bam card_ref.fasta 0.85 > s85.tsv
ok '[ "$(col s85.tsv 3000001 reads)" = 2 ] && [ "$(col s85.tsv 3000001 reads_low_identity)" = 1 ]' "X: 2 reads kept, 1 below 0.85"
ok '[ "$(col s85.tsv 3000001 aligned_bases)" = 100 ] && [ "$(col s85.tsv 3000001 mismatches)" = 0 ] && [ "$(col s85.tsv 3000001 covered_bases)" = 100 ]' "X: only the kept reads' bases, mismatches and coverage"
ok '[ "$(col s85.tsv 3000002 reads)" = 0 ] && [ "$(col s85.tsv 3000002 reads_low_identity)" = 1 ] && [ "$(col s85.tsv 3000002 window_mean)" = NA ]' "Y: listed with no reads kept"
ok '[ "$(col s85.tsv 3000001 canonical_length)" = 200 ]' "canonical length from the ARO's reference"

bash "$script" in.bam card_ref.fasta > s0.tsv
ok '[ "$(col s0.tsv 3000001 reads)" = 3 ] && [ "$(col s0.tsv 3000001 mismatches)" = 10 ] && [ "$(col s0.tsv 3000001 reads_low_identity)" = 0 ]' "no threshold: every read counted, mismatches from calmd"
ok '[ "$(col s0.tsv 3000002 reads)" = 1 ] && [ "$(col s0.tsv 3000002 mismatches)" = 20 ]' "no threshold: Y's read counted"

if [ "$fail" -gt 0 ]; then echo "test_rgi_read_stats.sh: $pass passed, $fail FAILED"; exit 1; fi
echo "test_rgi_read_stats.sh: all $pass checks passed"
