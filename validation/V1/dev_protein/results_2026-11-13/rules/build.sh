#!/opt/homebrew/bin/bash
# build.sh <round 3|4> <minid 0.70|0.90>: read_stats from the rerun hits, then resistome_tables.R offline
set -euo pipefail
r=$1; mid=$2; here=$(cd "$(dirname "$0")" && pwd); repo=~/Projects/seq-resistome
case $r in
 3) task=$(ls -d ~/Projects/seqcompendium-work/resistome-dev/r3work/aa/a3efc3*/); annot=~/Projects/seqcompendium-work/resistome-dev/r3work/c7/4e329dc381c4659d55638db9580a4d/card_protein_annotation.tsv;;
 4) task=$(ls -d ~/seqresistome-scratch/V1r4/work/26/263486*/); annot=$(ls ~/seqresistome-scratch/V1r4/work/2a/7258*/card_protein_annotation.tsv);;
esac
d=$here/r${r}_id${mid}; rm -rf "$d"; mkdir -p "$d"
cp -R "$task/rrna" "$task/input" "$d/"; mkdir "$d/rgi"; mkdir "$d/tmp"
for m1 in ~/Projects/seqcompendium-work/resistome-hits/hits/r$r/*.hits_1.tsv.gz; do
  s=$(basename "$m1" .hits_1.tsv.gz)
  gzip -dc "$m1" > "$d/tmp/h1.tsv"; gzip -dc "${m1/hits_1/hits_2}" > "$d/tmp/h2.tsv"
  (cd "$d/tmp" && bash "$repo/bin/protein_read_stats.sh" "$d/rgi/$s" "$annot" "$mid" h1.tsv h2.tsv)
done
rm -rf "$d/tmp"
cd "$d" && PATH=~/.conda/envs/seq-triage-dev/bin:$PATH Rscript "$repo/bin/resistome_tables.R" rgi rrna input/read_flow.tsv input/samples_left_out.tsv input/samplesheet.csv '4.0.2' true 1542 2 0.5 0.1.0dev 0.90 input/card_alleles.tsv 0.95 0 protein $mid > tables.log 2>&1
ls "$d" | head -20
