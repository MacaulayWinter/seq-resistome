#!/usr/bin/env bash
#*******************************************************************************
# fetch_reads.sh: stream the first N read pairs of an ENA run (validation V1)
#
# Only the first pairs are downloaded (the stream is cut once N pairs are
# read), so a 20-million-pair run costs a few hundred MB, not tens of GB.
# Both mates are checked to hold N complete records with matching names.
#
# Usage:  [SKIP=<pairs>] bash validation/V1/fetch_reads.sh <run_accession> <pairs> <out_prefix>
#         SKIP: leave out the first <pairs> pairs (round 2's E3 uses HG002's
#         pairs 200,001-400,000)
#         writes <out_prefix>_1.fastq.gz and <out_prefix>_2.fastq.gz
#*******************************************************************************
set -euo pipefail
run=$1; pairs=$2; out=$3; skip=${SKIP:-0}
urls=$(curl -sSf "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=$run&result=read_run&fields=fastq_ftp&format=tsv" | tail -n 1 | cut -f2)
for mate in 1 2; do
    url=$(printf '%s\n' "$urls" | tr ';' '\n' | grep "_${mate}.fastq.gz$")
    [ -n "$url" ] || { echo "$run: no _${mate}.fastq.gz on ENA" >&2; exit 1; }
    # head closes the pipe after N records, so curl and gzip upstream stop
    # with a broken pipe: expected, so pipefail is off for this line only.
    # The record counts and mate names below catch a short download.
    # Up to three attempts: a dropped connection mid-stream gives a short
    # file, which is caught by the count and tried again.
    for attempt in 1 2 3; do
        set +o pipefail
        curl -sS --retry 3 "https://$url" 2>/dev/null | gzip -dc 2>/dev/null | head -n $((4 * (skip + pairs))) | tail -n $((4 * pairs)) | gzip -1 > "${out}_${mate}.fastq.gz"
        set -o pipefail
        [ "$(gzip -dc "${out}_${mate}.fastq.gz" | awk 'END {print NR / 4}')" = "$pairs" ] && break
        echo "$run mate $mate: attempt $attempt short; retrying" >&2; sleep 10
    done
done
n1=$(gzip -dc "${out}_1.fastq.gz" | awk 'END {print NR / 4}'); n2=$(gzip -dc "${out}_2.fastq.gz" | awk 'END {print NR / 4}')
[ "$n1" = "$pairs" ] && [ "$n2" = "$pairs" ] || { echo "$run: got $n1 / $n2 records, wanted $pairs" >&2; exit 1; }
paste <(gzip -dc "${out}_1.fastq.gz" | awk 'NR % 4 == 1 {sub(/[ \/].*/, ""); print}') \
      <(gzip -dc "${out}_2.fastq.gz" | awk 'NR % 4 == 1 {sub(/[ \/].*/, ""); print}') | awk '$1 != $2 {bad++} END {exit bad > 0}' \
    || { echo "$run: mate names do not match" >&2; exit 1; }
echo "$run: $pairs pairs -> ${out}_1/2.fastq.gz"
