#!/usr/bin/env bash
#*******************************************************************************
# run_E4.sh: edge case E4, samples left out by a real seq-triage run
#            (PREREGISTRATION.md sections 1 and 3, mark 4)
#
# seq-triage (a clone at a fixed commit) runs on three samples: mixture M1
# (KPE111 in the gut background at 8x), KPE111's pure reads, and a 50-pair
# subsample of them. seq-resistome then runs on seq-triage's results. Pass:
# every sample seq-triage did not pass as a short-read metagenome is in
# samples_left_out.tsv with seq-triage's reason and in no other table; every
# sample it passed is analysed.
#
# Usage:  bash validation/V1/run_E4.sh <V1 scratch dir> <seq-triage repo> <kraken2 db dir> [nextflow args]
#*******************************************************************************
set -euo pipefail
v1=$(cd "$1" && pwd); triage_repo=$(cd "$2" && pwd); k2=$(cd "$3" && pwd); shift 3
repo=$(cd "$(dirname "$0")/../.." && pwd)
profile=${PROFILE:-docker}
e4=$v1/E4; mkdir -p "$e4"; r=$v1/reads
# Launch from E4's own folder: Nextflow writes its run history (.nextflow/)
# where it is launched, and the seq-triage clone must stay untouched.
cd "$e4"
g=GCF_051620725.1
set +o pipefail   # head stops reading early; the broken pipe upstream is expected
for m in 1 2; do gzip -dc "$r/pure_${g}_${m}.fastq.gz" | head -n 200 | gzip > "$e4/tiny_${m}.fastq.gz"; done
set -o pipefail
cat > "$e4/samplesheet_E4.csv" <<EOF
sample,fastq_1,fastq_2,site
E4_mixture,$r/mix_gut_${g}_8x_1.fastq.gz,$r/mix_gut_${g}_8x_2.fastq.gz,gut
E4_isolate,$r/pure_${g}_1.fastq.gz,$r/pure_${g}_2.fastq.gz,isolate
E4_tiny,$e4/tiny_1.fastq.gz,$e4/tiny_2.fastq.gz,isolate
EOF
echo "seq-triage commit: $(git -C "$triage_repo" rev-parse --short HEAD)" | tee "$e4/versions.txt"

echo "== seq-triage"
nextflow -log "$e4/triage.log" run "$triage_repo/main.nf" -profile "$profile" -work-dir "$e4/work_triage" \
    --input "$e4/samplesheet_E4.csv" --outdir "$e4/triage" --kraken2_db "$k2" --kraken2_memory_mapping "$@"
cut -f1-3,23 "$e4/triage/triage_summary.tsv"

echo "== seq-resistome on seq-triage's results"
nextflow -log "$e4/resistome.log" run "$repo/main.nf" -profile "$profile" -work-dir "$v1/work" \
    --input "$e4/samplesheet_E4.csv" --triage_results "$e4/triage" --outdir "$e4/resistome" "$@" || true
# If seq-triage passed none, seq-resistome stops ("No sample is left to analyse"):
# that is the right behaviour, and the check below still applies.

echo "== score"
python3 -I - "$e4" <<'PY'
import csv, sys, os
e4 = sys.argv[1]
tri = {r["sample"]: r for r in csv.DictReader(open(f"{e4}/triage/triage_summary.tsv"), delimiter="\t")}
def rows(f):
    p = f"{e4}/resistome/{f}"
    if not os.path.exists(p): return []
    return list(csv.DictReader((l for l in open(p) if not l.startswith("#")), delimiter="\t"))
left = {r["sample"]: r["reason"] for r in rows("samples_left_out.tsv")}
den = {r["sample"] for r in rows("denominators.tsv")}
longs = {r["sample"] for r in rows("arg_long.tsv")}
log = open(f"{e4}/resistome.log").read()
ok = True
out = [["sample", "seq-triage verdict", "detected type", "platform", "expected", "observed", "pass"]]
for s, t in tri.items():
    passed = t["verdict"] in ("PASS", "WARN") and t["detected_type"] == "metagenome" and t["detected_platform"] in ("illumina", "dnbseq", "element")
    if passed:
        obs = "analysed" if s in den and s not in left else "NOT analysed"
        good = obs == "analysed"
    else:
        in_left = s in left or (not den and f"{s} (" in log)     # all left out: the stop message lists each with its reason
        obs = f"left out: {left.get(s, 'listed in the stop message')}" if in_left else "NOT left out"
        good = in_left and s not in den and s not in longs
    ok &= good
    out.append([s, t["verdict"], t["detected_type"], t["detected_platform"], "analysed" if passed else "left out", obs, "pass" if good else "FAIL"])
with open(f"{e4}/E4_outcome.tsv", "w") as f:
    csv.writer(f, delimiter="\t", lineterminator="\n").writerows(out + [["E4", "", "", "", "", "", "PASS" if ok else "FAIL"]])
for r in out: print("\t".join(r))
print("E4:", "PASS" if ok else "FAIL")
PY
